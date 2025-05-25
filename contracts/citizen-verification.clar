;; Citizen Verification Contract
;; Validates and manages citizen identities for feedback submission

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_VERIFIED (err u102))

;; Data structures
(define-map verified-citizens principal bool)
(define-map citizen-details principal {
  name: (string-ascii 50),
  verification-date: uint,
  is-active: bool
})

;; Verification status tracking
(define-data-var total-verified-citizens uint u0)

;; Public functions
(define-public (verify-citizen (citizen principal) (name (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? verified-citizens citizen)) ERR_ALREADY_VERIFIED)

    (map-set verified-citizens citizen true)
    (map-set citizen-details citizen {
      name: name,
      verification-date: block-height,
      is-active: true
    })
    (var-set total-verified-citizens (+ (var-get total-verified-citizens) u1))
    (ok true)
  )
)

(define-public (deactivate-citizen (citizen principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? verified-citizens citizen)) ERR_NOT_VERIFIED)

    (map-set citizen-details citizen
      (merge (unwrap-panic (map-get? citizen-details citizen)) { is-active: false }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (is-verified-citizen (citizen principal))
  (default-to false (map-get? verified-citizens citizen))
)

(define-read-only (get-citizen-details (citizen principal))
  (map-get? citizen-details citizen)
)

(define-read-only (get-total-verified-citizens)
  (var-get total-verified-citizens)
)

(define-read-only (is-active-citizen (citizen principal))
  (match (map-get? citizen-details citizen)
    details (get is-active details)
    false
  )
)
