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