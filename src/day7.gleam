import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile.{read}

const example = "
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"

pub fn main() {
  let assert 3749 = part1(example)
  let assert 11_387 = part2(example)
  let assert Ok(input) = read(from: "./input/day7.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  input
  |> to_equations
  |> list.filter(valid_equation(_, [int.add, int.multiply]))
  |> list.map(pair.first)
  |> int.sum
}

pub fn part2(input) {
  input
  |> to_equations
  |> list.filter(valid_equation(_, [int.add, int.multiply, concat]))
  |> list.map(pair.first)
  |> int.sum
}

fn to_equations(input) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.filter_map(string.split_once(_, ": "))
  |> list.map(fn(x) {
    #(
      result.unwrap(x.0 |> int.parse, 0),
      x.1 |> string.split(" ") |> list.filter_map(int.parse),
    )
  })
}

fn valid_equation(equation, operators) {
  let #(test_value, nums) = equation
  valid_equation_loop(test_value, nums, operators)
}

fn valid_equation_loop(test_value, nums, operators) {
  case nums {
    [a, b] -> operators |> list.any(fn(op) { op(a, b) == test_value })
    [a, b, ..rest] -> {
      operators
      |> list.any(fn(op) {
        let value = op(a, b)
        value <= test_value
        && valid_equation_loop(test_value, [value, ..rest], operators)
      })
    }
    _ -> True
  }
}

fn concat(a, b) {
  case int.parse(a |> int.to_string <> b |> int.to_string) {
    Ok(x) -> x
    Error(_) -> panic
  }
}
