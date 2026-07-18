/// Does the operation a + b
pub fn add_two_numbers(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_addition() {
        assert_eq!(add_two_numbers(5, 7), 5 + 7);
    }
}
