;; experiments.clar - Advanced Implementation

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u403))
(define-constant ERR_INVALID_DATA (err u400))

(define-data-var last-experiment-id uint u0)

;; Enhanced experiment status tracking
(define-map experiment-status-history 
    { experiment-id: uint, status-id: uint }
    {
        status: (string-ascii 20),
        timestamp: uint,
        updated-by: principal,
        notes: (optional (string-utf8 500))
    }
)

(define-map experiments
    { experiment-id: uint }
    {
        researcher: principal,
        timestamp: uint,
        parasite-type: (string-ascii 64),
        host-type: (string-ascii 64),
        methodology: (string-utf8 500),
        results: (string-utf8 1000),
        status: (string-ascii 20),
        last-status-id: uint,
        reviewers: (list 5 principal),
        is-verified: bool
    }
)

;; Trait for experiment verification
(define-trait experiment-verifier
    (
        (verify-experiment (uint) (response bool uint))
    )
)

(define-public (create-experiment (parasite-type (string-ascii 64)) 
                                (host-type (string-ascii 64))
                                (methodology (string-utf8 500)))
    (let ((new-id (+ (var-get last-experiment-id) u1)))
        (asserts! (is-valid-researcher tx-sender) ERR_NOT_AUTHORIZED)
        (try! (create-initial-status new-id))
        (map-insert experiments
            { experiment-id: new-id }
            {
                researcher: tx-sender,
                timestamp: block-height,
                parasite-type: parasite-type,
                host-type: host-type,
                methodology: methodology,
                results: u"",
                status: "INITIATED",
                last-status-id: u1,
                reviewers: (list ),
                is-verified: false
            })
        (var-set last-experiment-id new-id)
        (ok new-id)))

(define-public (update-experiment-status 
    (experiment-id uint) 
    (new-status (string-ascii 20))
    (notes (optional (string-utf8 500))))
    (let ((experiment (unwrap! (get-experiment experiment-id) ERR_NOT_FOUND))
          (current-status (get status experiment)))
        (asserts! (is-authorized-for-experiment experiment-id) ERR_NOT_AUTHORIZED)
        (asserts! (is-valid-status-transition current-status new-status) ERR_INVALID_STATUS)
        (try! (record-status-change experiment-id new-status notes))
        (ok true)))

(define-private (create-initial-status (experiment-id uint))
    (if (map-insert experiment-status-history
        { experiment-id: experiment-id, status-id: u1 }
        {
            status: "INITIATED",
            timestamp: block-height,
            updated-by: tx-sender,
            notes: none
        })
        (ok true)
        ERR_INVALID_DATA))

(define-private (is-valid-researcher (address principal))
    (is-some (contract-call? .laboratory get-researcher address)))

(define-private (is-authorized-for-experiment (experiment-id uint))
    (let ((experiment (unwrap! (get-experiment experiment-id) false)))
        (or
            (is-eq tx-sender (get researcher experiment))
            (is-reviewer experiment-id tx-sender))))

(define-private (is-reviewer (experiment-id uint) (address principal))
    (let ((experiment (unwrap! (get-experiment experiment-id) false)))
        (is-some (index-of (get reviewers experiment) address))))

(define-private (record-status-change 
    (experiment-id uint) 
    (new-status (string-ascii 20))
    (notes (optional (string-utf8 500))))
    (let ((experiment (unwrap! (get-experiment experiment-id) ERR_NOT_FOUND))
          (new-status-id (+ (get last-status-id experiment) u1)))
        (if (map-insert experiment-status-history
            { experiment-id: experiment-id, status-id: new-status-id }
            {
                status: new-status,
                timestamp: block-height,
                updated-by: tx-sender,
                notes: notes
            })
            (ok true)
            ERR_INVALID_DATA)))

(define-private (is-valid-status-transition (current (string-ascii 20)) (new (string-ascii 20)))
    (or
        (and (is-eq current "INITIATED") (is-eq new "IN_PROGRESS"))
        (and (is-eq current "IN_PROGRESS") (is-eq new "REVIEW"))
        (and (is-eq current "REVIEW") (is-eq new "COMPLETED"))
        (and (is-eq current "REVIEW") (is-eq new "REVISION_NEEDED"))))

(define-read-only (get-experiment-status-history (experiment-id uint))
    (map-get? experiment-status-history { experiment-id: experiment-id, status-id: u1 }))

(define-read-only (get-experiment (experiment-id uint))
    (map-get? experiments { experiment-id: experiment-id }))
