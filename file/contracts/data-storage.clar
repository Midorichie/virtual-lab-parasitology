;; data-storage.clar
;; Handles permanent storage of experimental data

(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

;; Data structures
(define-map experimental-data
    { data-id: uint }
    {
        experiment-id: uint,
        data-type: (string-ascii 64),
        hash: (buff 32),
        timestamp: uint
    }
)

(define-data-var last-data-id uint u0)

;; Public functions
(define-public (store-data (experiment-id uint) 
                          (data-type (string-ascii 64))
                          (data-hash (buff 32)))
    (let
        ((data-id (+ (var-get last-data-id) u1)))
        (map-insert experimental-data
            { data-id: data-id }
            {
                experiment-id: experiment-id,
                data-type: data-type,
                hash: data-hash,
                timestamp: block-height
            })
        (var-set last-data-id data-id)
        (ok data-id)
    )
)
