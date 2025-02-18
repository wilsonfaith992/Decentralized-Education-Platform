;; Course Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-enrolled (err u102))
(define-constant err-not-enrolled (err u103))

;; Data Variables
(define-data-var course-nonce uint u0)

;; Data Maps
(define-map courses
  { course-id: uint }
  {
    instructor: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    price: uint,
    duration: uint
  }
)

(define-map enrollments
  { course-id: uint, student: principal }
  {
    progress: uint,
    completed: bool
  }
)

;; Public Functions

;; Create a new course
(define-public (create-course (title (string-ascii 100)) (description (string-utf8 1000)) (price uint) (duration uint))
  (let
    (
      (course-id (var-get course-nonce))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set courses
      { course-id: course-id }
      {
        instructor: tx-sender,
        title: title,
        description: description,
        price: price,
        duration: duration
      }
    )
    (var-set course-nonce (+ course-id u1))
    (ok course-id)
  )
)

;; Enroll in a course
(define-public (enroll-course (course-id uint))
  (let
    (
      (course (unwrap! (map-get? courses { course-id: course-id }) err-not-found))
    )
    (asserts! (is-none (map-get? enrollments { course-id: course-id, student: tx-sender })) err-already-enrolled)
    (map-set enrollments
      { course-id: course-id, student: tx-sender }
      {
        progress: u0,
        completed: false
      }
    )
    (ok true)
  )
)

;; Update student progress
(define-public (update-progress (course-id uint) (new-progress uint))
  (let
    (
      (enrollment (unwrap! (map-get? enrollments { course-id: course-id, student: tx-sender }) err-not-enrolled))
    )
    (asserts! (<= new-progress u100) (err u104))
    (map-set enrollments
      { course-id: course-id, student: tx-sender }
      (merge enrollment {
        progress: new-progress,
        completed: (>= new-progress u100)
      })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get course details
(define-read-only (get-course (course-id uint))
  (ok (unwrap! (map-get? courses { course-id: course-id }) err-not-found))
)

;; Get enrollment details
(define-read-only (get-enrollment (course-id uint) (student principal))
  (ok (unwrap! (map-get? enrollments { course-id: course-id, student: student }) err-not-enrolled))
)

;; Initialize contract
(begin
  (var-set course-nonce u0)
)

