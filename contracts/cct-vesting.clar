(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-beneficiary (err u201))
(define-constant err-invalid-params (err u202))
(define-constant err-revoked (err u203))
(define-constant err-nothing-to-claim (err u204))

(define-data-var next-vesting-id uint u1)

(define-map vestings
    uint
    {
        beneficiary: principal,
        start: uint,
        end: uint,
        total: uint,
        claimed: uint,
        revoked: bool,
    }
)

(define-read-only (get-vesting (id uint))
    (map-get? vestings id)
)

(define-read-only (get-claimable (id uint))
    (match (map-get? vestings id)
        v (let (
                (now stacks-block-height)
                (start (get start v))
                (end (get end v))
                (total (get total v))
                (claimed (get claimed v))
                (vesting-length (- end start))
                (vested (if (or (<= now start) (<= vesting-length u0))
                            u0
                            (if (>= now end)
                                total
                                (/ (* total (- now start)) vesting-length)
                            )
                        ))
                (claimable (if (> vested claimed) (- vested claimed) u0))
            )
            (ok claimable)
        )
        (ok u0)
    )
)

(define-public (create-vesting (beneficiary principal) (total uint) (start uint) (end uint))
    (let ((id (var-get next-vesting-id)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (and (> total u0) (< start end)) err-invalid-params)
        (map-set vestings id {
            beneficiary: beneficiary,
            start: start,
            end: end,
            total: total,
            claimed: u0,
            revoked: false,
        })
        (var-set next-vesting-id (+ id u1))
        (ok id)
    )
)

(define-public (revoke-vesting (id uint))
    (let ((v (unwrap! (map-get? vestings id) err-invalid-params)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (get revoked v)) err-revoked)
        (ok (map-set vestings id (merge v { revoked: true })))
    )
)

(define-public (claim-vesting (id uint))
    (let ((v (unwrap! (map-get? vestings id) err-invalid-params)))
        (let (
                (beneficiary (get beneficiary v))
                (now stacks-block-height)
                (start (get start v))
                (end (get end v))
                (total (get total v))
                (claimed (get claimed v))
                (vesting-length (- end start))
                (vested (if (or (<= now start) (<= vesting-length u0))
                            u0
                            (if (>= now end)
                                total
                                (/ (* total (- now start)) vesting-length)
                            )
                        ))
                (claimable (if (> vested claimed) (- vested claimed) u0))
            )
            (begin
                (asserts! (is-eq tx-sender beneficiary) err-not-beneficiary)
                (asserts! (not (get revoked v)) err-revoked)
                (asserts! (> claimable u0) err-nothing-to-claim)
                (map-set vestings id (merge v { claimed: (+ claimed claimable) }))
                (as-contract (try! (contract-call? .Clean-Cooking-Token- transfer claimable tx-sender beneficiary none)))
                (ok claimable)
            )
        )
    )
)
