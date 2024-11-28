;; experiments.clar
;; Core contract for managing parasitology experiments

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

;; Data structures
(define-data-var last-experiment-id uint u0)

(define-map experiments
    { experiment-id: uint }
    {
        researcher: principal,
        timestamp: uint,
        parasite-type: (string-ascii 64),
        host-type: (string-ascii 64),
        methodology: (string-utf8 500),
        results: (string-utf8 1000),
        status: (string-ascii 20)
    }
)

;; Public functions
(define-public (create-experiment (parasite-type (string-ascii 64)) 
                                (host-type (string-ascii 64))
                                (methodology (string-utf8 500)))
    (let
        ((new-id (+ (var-get last-experiment-id) u1)))
        (map-insert experiments
            { experiment-id: new-id }
            {
                researcher: tx-sender,
                timestamp: block-height,
                parasite-type: parasite-type,
                host-type: host-type,
                methodology: methodology,
                results: u"",
                status: "IN_PROGRESS"
            })
        (var-set last-experiment-id new-id)
        (ok new-id)
    )
)

;; Read-only functions
(define-read-only (get-experiment (experiment-id uint))
    (map-get? experiments { experiment-id: experiment-id })
)
