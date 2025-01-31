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