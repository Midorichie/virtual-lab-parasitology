;; laboratory.clar
;; Manages laboratory access and equipment

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

;; Data structures
(define-map researchers
    { address: principal }
    {
        access-level: (string-ascii 20),
        specialization: (string-ascii 64),
        experiments-count: uint
    }
)

;; Public functions
(define-public (register-researcher (specialization (string-ascii 64)))
    (begin
        (map-insert researchers
            { address: tx-sender }
            {
                access-level: "RESEARCHER",
                specialization: specialization,
                experiments-count: u0
            })
        (ok true))
)

;; Read-only functions
(define-read-only (get-researcher (address principal))
    (map-get? researchers { address: address })
)
