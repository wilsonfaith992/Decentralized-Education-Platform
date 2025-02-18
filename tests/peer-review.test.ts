import { describe, it, expect } from "vitest"

// Mock the Clarity functions and types
const mockClarity = {
  tx: {
    sender: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  },
  types: {
    uint: (value: number) => ({ type: "uint", value }),
    principal: (value: string) => ({ type: "principal", value }),
    string: (value: string) => ({ type: "string", value }),
  },
}

// Mock contract calls
const contractCalls = {
  "submit-review": (courseId: number, reviewee: string, rating: number, comment: string) => {
    return { success: true, value: mockClarity.types.uint(0) }
  },
  "get-review": (reviewId: number) => {
    return {
      success: true,
      value: {
        "course-id": mockClarity.types.uint(0),
        reviewer: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
        reviewee: mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
        rating: mockClarity.types.uint(5),
        comment: mockClarity.types.string("Great student!"),
      },
    }
  },
  "get-review-by-users": (courseId: number, reviewer: string, reviewee: string) => {
    return {
      success: true,
      value: {
        "course-id": mockClarity.types.uint(0),
        reviewer: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
        reviewee: mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
        rating: mockClarity.types.uint(5),
        comment: mockClarity.types.string("Great student!"),
      },
    }
  },
}

describe("Peer Review Contract", () => {
  it("should submit a review", () => {
    const result = contractCalls["submit-review"](0, "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG", 5, "Great student!")
    expect(result.success).toBe(true)
    expect(result.value).toEqual(mockClarity.types.uint(0))
  })
  
  it("should get review details", () => {
    const result = contractCalls["get-review"](0)
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      "course-id": mockClarity.types.uint(0),
      reviewer: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
      reviewee: mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
      rating: mockClarity.types.uint(5),
      comment: mockClarity.types.string("Great student!"),
    })
  })
  
  it("should get review by users", () => {
    const result = contractCalls["get-review-by-users"](
        0,
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
        "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
    )
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      "course-id": mockClarity.types.uint(0),
      reviewer: mockClarity.types.principal("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"),
      reviewee: mockClarity.types.principal("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"),
      rating: mockClarity.types.uint(5),
      comment: mockClarity.types.string("Great student!"),
    })
  })
})

