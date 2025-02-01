;; Title: Decentralized Event Insurance Contract
;; Description: Smart contract for event cancellation insurance with automated claims

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_AMOUNT (err u2))
(define-constant ERR_EVENT_EXISTS (err u3))
(define-constant ERR_EVENT_NOT_FOUND (err u4))
(define-constant ERR_ALREADY_INSURED (err u5))
(define-constant ERR_NOT_INSURED (err u6))
(define-constant ERR_ALREADY_CLAIMED (err u7))
(define-constant ERR_EVENT_ACTIVE (err u8))
(define-constant ERR_INVALID_DATE (err u9))

;; Event status types
(define-data-var CLAIM_WINDOW_BLOCKS u10000)

;; Data Maps
(define-map events 
    { event-id: uint } 
    {
        organizer: principal,
        event-date: uint,
        total-insurance-pool: uint,
        premium-amount: uint,
        max-participants: uint,
        current-participants: uint,
        is-cancelled: bool,
        claim-deadline: uint
    }

    (define-map insurance-policies
    { event-id: uint, participant: principal }
    {
        amount: uint,
        claimed: bool
    }
)

(define-map event-verifiers
    { event-id: uint }
    {
        weather-oracle: principal,
        venue-oracle: principal,
        government-oracle: principal
    }
)

;; Public Functions

(define-public (register-event 
    (event-id uint) 
    (event-date uint)
    (premium-amount uint)
    (max-participants uint))
    (let
        ((sender tx-sender))
        ;; Validate inputs
        (asserts! (> event-date block-height) ERR_INVALID_DATE)
        (asserts! (> premium-amount u0) ERR_INVALID_AMOUNT)
        (asserts! (> max-participants u0) ERR_INVALID_AMOUNT)
        ;; Check event doesn't exist
        (asserts! (is-none (map-get? events { event-id: event-id })) ERR_EVENT_EXISTS)
        
        (ok (map-set events
            { event-id: event-id }
            {
                organizer: sender,
                event-date: event-date,
                total-insurance-pool: u0,
                premium-amount: premium-amount,
                max-participants: max-participants,
                current-participants: u0,
                is-cancelled: false,
                claim-deadline: (+ event-date (var-get CLAIM_WINDOW_BLOCKS))
            }
        ))
    )
)

(define-public (purchase-insurance (event-id uint))
    (let
        ((sender tx-sender)
         (event (unwrap! (map-get? events { event-id: event-id }) ERR_EVENT_NOT_FOUND))
         (policy (map-get? insurance-policies { event-id: event-id, participant: sender })))
        
        ;; Validate purchase
        (asserts! (is-none policy) ERR_ALREADY_INSURED)
        (asserts! (< (get current-participants event) (get max-participants event)) ERR_INVALID_AMOUNT)
        (asserts! (not (get is-cancelled event)) ERR_EVENT_ACTIVE)
        
        ;; Process payment
        (try! (stx-transfer? (get premium-amount event) sender (as-contract tx-sender)))
        
        ;; Update event stats
        (map-set events
            { event-id: event-id }
            (merge event {
                total-insurance-pool: (+ (get total-insurance-pool event) (get premium-amount event)),
                current-participants: (+ (get current-participants event) u1)
            })
        )
        
        ;; Create policy
        (ok (map-set insurance-policies
            { event-id: event-id, participant: sender }
            {
                amount: (get premium-amount event),
                claimed: false
            }
        ))
    )
)
(define-public (cancel-event (event-id uint))
    (let
        ((sender tx-sender)
         (event (unwrap! (map-get? events { event-id: event-id }) ERR_EVENT_NOT_FOUND)))
        
        ;; Verify authorization
        (asserts! (or 
            (is-eq sender (get organizer event))
            (is-authorized-verifier event-id sender)
        ) ERR_UNAUTHORIZED)
        
        ;; Update event status
        (ok (map-set events
            { event-id: event-id }
            (merge event { is-cancelled: true })
        ))
    )
)

(define-public (claim-insurance (event-id uint))
    (let
        ((sender tx-sender)
         (event (unwrap! (map-get? events { event-id: event-id }) ERR_EVENT_NOT_FOUND))
         (policy (unwrap! (map-get? insurance-policies { event-id: event-id, participant: sender }) ERR_NOT_INSURED)))
        
        ;; Validate claim
        (asserts! (get is-cancelled event) ERR_EVENT_ACTIVE)
        (asserts! (not (get claimed policy)) ERR_ALREADY_CLAIMED)
        (asserts! (<= block-height (get claim-deadline event)) ERR_INVALID_DATE)
        
        ;; Process claim
        (try! (as-contract (stx-transfer? 
            (calculate-payout event-id (get amount policy))
            tx-sender
            sender
        )))
        
        ;; Update policy
        (ok (map-set insurance-policies
            { event-id: event-id, participant: sender }
            (merge policy { claimed: true })
        ))
    )
)
;; Read-Only Functions

(define-read-only (get-event-details (event-id uint))
    (map-get? events { event-id: event-id })
)

(define-read-only (get-policy-details (event-id uint) (participant principal))
    (map-get? insurance-policies { event-id: event-id, participant: participant })
)

(define-read-only (is-authorized-verifier (event-id uint) (verifier principal))
    (match (map-get? event-verifiers { event-id: event-id })
        verifiers (or
            (is-eq verifier (get weather-oracle verifiers))
            (is-eq verifier (get venue-oracle verifiers))
            (is-eq verifier (get government-oracle verifiers))
        )
        false
    )
)

;; Private Functions

(define-private (calculate-payout (event-id uint) (premium-amount uint))
    ;; Simple payout calculation - could be made more complex based on requirements
    (let
        ((event (unwrap-panic (map-get? events { event-id: event-id }))))
        (* premium-amount u2) ;; Example: 2x premium payout
    )
)