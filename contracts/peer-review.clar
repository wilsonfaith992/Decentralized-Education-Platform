;; Peer Review Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-reviewed (err u103))

;; Data Variables
(define-data-var review-nonce uint u0)

;; Data Maps
(define-map reviews
  { review-id: uint }
  {
    course-id: uint,
    reviewer: principal,
    reviewee: principal,
    rating: uint,
    comment: (string-utf8 500)
  }
)

(define-map user-reviews
  { course-id: uint, reviewer: principal, reviewee: principal }
  { review-id: uint }
)

;; Public Functions

;; Submit a peer review
(define-public (submit-review (course-id uint) (reviewee principal) (rating uint) (comment (string-utf8 500)))
  (let
    (
      (review-id (var-get review-nonce))
      (enrollment-reviewer (unwrap! (contract-call? .course get-enrollment course-id tx-sender) err-unauthorized))
      (enrollment-reviewee (unwrap! (contract-call? .course get-enrollment course-id reviewee) err-unauthorized))
    )
    (asserts! (and (>= rating u1) (<= rating u5)) (err u104))
    (asserts! (is-none (map-get? user-reviews { course-id: course-id, reviewer: tx-sender, reviewee: reviewee })) err-already-reviewed)
    (map-set reviews
      { review-id: review-id }
      {
        course-id: course-id,
        reviewer: tx-sender,
        reviewee: reviewee,
        rating: rating,
        comment: comment
      }
    )
    (map-set user-reviews
      { course-id: course-id, reviewer: tx-sender, reviewee: reviewee }
      { review-id: review-id }
    )
    (var-set review-nonce (+ review-id u1))
    (ok review-id)
  )
)

;; Read-only Functions

;; Get review details
(define-read-only (get-review (review-id uint))
  (ok (unwrap! (map-get? reviews { review-id: review-id }) err-not-found))
)

;; Get review by course, reviewer, and reviewee
(define-read-only (get-review-by-users (course-id uint) (reviewer principal) (reviewee principal))
  (let
    (
      (review-id (get review-id (unwrap! (map-get? user-reviews { course-id: course-id, reviewer: reviewer, reviewee: reviewee }) err-not-found)))
    )
    (ok (unwrap! (map-get? reviews { review-id: review-id }) err-not-found))
  )
)

;; Initialize contract
(begin
  (var-set review-nonce u0)
)

