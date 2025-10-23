(define-fungible-token clean-cooking-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-already-claimed (err u105))
(define-constant err-invalid-stove (err u106))
(define-constant err-cooldown-active (err u107))
(define-constant err-stove-not-registered (err u108))

(define-constant token-name "Clean Cooking Token")
(define-constant token-symbol "CCT")
(define-constant token-decimals u6)
(define-constant total-supply u1000000000000)
(define-constant daily-reward u100000)
(define-constant stove-registration-reward u500000)
(define-constant efficiency-bonus-multiplier u2)
(define-constant cooldown-period u144)

(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var next-stove-id uint u1)

(define-map stoves
    uint
    {
        owner: principal,
        stove-type: (string-ascii 32),
        efficiency-rating: uint,
        registration-block: uint,
        total-usage-hours: uint,
        is-verified: bool,
    }
)

(define-map user-stoves
    principal
    (list 10 uint)
)

(define-map daily-claims
    {
        user: principal,
        day: uint,
    }
    {
        amount: uint,
        timestamp: uint,
    }
)

(define-map user-stats
    principal
    {
        total-earned: uint,
        total-cooking-hours: uint,
        efficiency-score: uint,
        last-claim-block: uint,
    }
)

(define-map authorized-verifiers
    principal
    bool
)

(define-read-only (get-name)
    (ok token-name)
)

(define-read-only (get-symbol)
    (ok token-symbol)
)

(define-read-only (get-decimals)
    (ok token-decimals)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance clean-cooking-token who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply clean-cooking-token))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-read-only (get-stove-info (stove-id uint))
    (map-get? stoves stove-id)
)

(define-read-only (get-user-stoves (user principal))
    (default-to (list) (map-get? user-stoves user))
)

(define-read-only (get-user-stats (user principal))
    (map-get? user-stats user)
)

(define-read-only (get-daily-claim-info
        (user principal)
        (day uint)
    )
    (map-get? daily-claims {
        user: user,
        day: day,
    })
)

(define-read-only (calculate-current-day)
    (/ stacks-block-height u144)
)

(define-read-only (calculate-efficiency-reward
        (base-amount uint)
        (efficiency uint)
    )
    (if (>= efficiency u8)
        (* base-amount efficiency-bonus-multiplier)
        base-amount
    )
)

(define-read-only (is-authorized-verifier (verifier principal))
    (default-to false (map-get? authorized-verifiers verifier))
)

(define-read-only (can-claim-daily-reward (user principal))
    (let (
            (current-day (calculate-current-day))
            (user-data (get-user-stats user))
        )
        (and
            (is-some user-data)
            (is-none (get-daily-claim-info user current-day))
            (> (len (get-user-stoves user)) u0)
        )
    )
)

(define-public (transfer
        (amount uint)
        (from principal)
        (to principal)
        (memo (optional (buff 34)))
    )
    (begin
        (asserts! (or (is-eq from tx-sender) (is-eq from contract-caller))
            err-not-token-owner
        )
        (ft-transfer? clean-cooking-token amount from to)
    )
)

(define-public (mint
        (amount uint)
        (to principal)
    )
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? clean-cooking-token amount to)
    )
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (var-set token-uri new-uri))
    )
)

(define-public (add-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-verifiers verifier true))
    )
)

(define-public (remove-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-delete authorized-verifiers verifier))
    )
)

(define-public (register-stove
        (stove-type (string-ascii 32))
        (efficiency-rating uint)
    )
    (let (
            (stove-id (var-get next-stove-id))
            (current-stoves (get-user-stoves tx-sender))
        )
        (asserts! (<= efficiency-rating u10) err-invalid-amount)
        (asserts! (< (len current-stoves) u10) err-invalid-amount)

        (map-set stoves stove-id {
            owner: tx-sender,
            stove-type: stove-type,
            efficiency-rating: efficiency-rating,
            registration-block: stacks-block-height,
            total-usage-hours: u0,
            is-verified: false,
        })

        (map-set user-stoves tx-sender
            (unwrap! (as-max-len? (append current-stoves stove-id) u10)
                err-invalid-amount
            ))

        (var-set next-stove-id (+ stove-id u1))

        (try! (ft-mint? clean-cooking-token stove-registration-reward tx-sender))
        (ok stove-id)
    )
)

(define-public (verify-stove (stove-id uint))
    (let ((stove (unwrap! (map-get? stoves stove-id) err-stove-not-registered)))
        (asserts! (is-authorized-verifier tx-sender) err-unauthorized)

        (ok (map-set stoves stove-id (merge stove { is-verified: true })))
    )
)

(define-public (log-cooking-session
        (stove-id uint)
        (hours uint)
    )
    (let ((stove (unwrap! (map-get? stoves stove-id) err-stove-not-registered)))
        (asserts! (is-eq (get owner stove) tx-sender) err-not-token-owner)
        (asserts! (get is-verified stove) err-invalid-stove)
        (asserts! (and (> hours u0) (<= hours u24)) err-invalid-amount)

        (map-set stoves stove-id
            (merge stove { total-usage-hours: (+ (get total-usage-hours stove) hours) })
        )

        (let ((current-stats (default-to {
                total-earned: u0,
                total-cooking-hours: u0,
                efficiency-score: u0,
                last-claim-block: u0,
            }
                (get-user-stats tx-sender)
            )))
            (ok (map-set user-stats tx-sender
                (merge current-stats { total-cooking-hours: (+ (get total-cooking-hours current-stats) hours) })
            ))
        )
    )
)

(define-public (claim-daily-reward)
    (let (
            (current-day (calculate-current-day))
            (user-data (get-user-stats tx-sender))
            (user-stove-list (get-user-stoves tx-sender))
        )
        (asserts! (> (len user-stove-list) u0) err-stove-not-registered)
        (asserts! (can-claim-daily-reward tx-sender) err-already-claimed)

        (let (
                (avg-efficiency (fold calculate-avg-efficiency user-stove-list u0))
                (base-reward daily-reward)
                (final-reward (calculate-efficiency-reward base-reward avg-efficiency))
                (current-stats (default-to {
                    total-earned: u0,
                    total-cooking-hours: u0,
                    efficiency-score: avg-efficiency,
                    last-claim-block: stacks-block-height,
                }
                    user-data
                ))
            )
            (map-set daily-claims {
                user: tx-sender,
                day: current-day,
            } {
                amount: final-reward,
                timestamp: stacks-block-height,
            })

            (map-set user-stats tx-sender
                (merge current-stats {
                    total-earned: (+ (get total-earned current-stats) final-reward),
                    efficiency-score: avg-efficiency,
                    last-claim-block: stacks-block-height,
                })
            )

            (ft-mint? clean-cooking-token final-reward tx-sender)
        )
    )
)

(define-private (calculate-avg-efficiency
        (stove-id uint)
        (acc uint)
    )
    (match (map-get? stoves stove-id)
        stove-data (+ acc (get efficiency-rating stove-data))
        acc
    )
)

(define-public (emergency-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok true)
    )
)

(begin
    (try! (ft-mint? clean-cooking-token total-supply contract-owner))
    (map-set authorized-verifiers contract-owner true)
)
(define-private (batch-transfer-step
        (item {
            to: principal,
            amount: uint,
        })
        (acc (response bool uint))
    )
    (match acc
        okv (ft-transfer? clean-cooking-token (get amount item) tx-sender
            (get to item)
        )
        errv
        acc
    )
)

(define-public (batch-transfer (transfers (list 50 {
    to: principal,
    amount: uint,
})))
    (begin
        (asserts! (> (len transfers) u0) err-invalid-amount)
        (fold batch-transfer-step transfers (ok true))
    )
)
