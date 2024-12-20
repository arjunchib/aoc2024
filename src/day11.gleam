import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import rememo/memo
import simplifile.{read}

const example = "125 17"

pub fn main() {
  let assert 55_312 = part1(example)
  let assert Ok(input) = read(from: "./input/day11.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  use cache <- memo.create()
  input |> parse_input |> blink(25, cache)
}

pub fn part2(input) {
  use cache <- memo.create()
  input |> parse_input |> blink(75, cache)
}

fn parse_input(input) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.filter_map(int.parse)
}

fn blink(stones, i, cache) {
  case i {
    0 -> stones |> list.length
    _ ->
      stones
      |> list.map(fn(stone) {
        use <- memo.memoize(cache, #(stone, i))
        let stone_str = stone |> int.to_string
        let stone_len = stone_str |> string.length
        let new_stones = case stone {
          0 -> [1]
          _ if stone_len % 2 == 0 -> {
            let n1 = stone_str |> string.slice(0, stone_len / 2) |> parse_int
            let n2 =
              stone_str
              |> string.slice(stone_len / 2, stone_len / 2)
              |> parse_int
            [n1, n2]
          }
          _ -> [stone * 2024]
        }
        blink(new_stones, i - 1, cache)
      })
      |> int.sum
  }
}

// fn blink(stones, i) {
//   let stones =
//     stones
//     |> list.flat_map(fn(stone) {
//       let stone_str = stone |> int.to_string
//       let stone_len = stone_str |> string.length
//       case stone {
//         0 -> [1]
//         _ if stone_len % 2 == 0 -> {
//           let n1 = stone_str |> string.slice(0, stone_len / 2) |> parse_int
//           let n2 =
//             stone_str
//             |> string.slice(stone_len / 2, stone_len / 2)
//             |> parse_int
//           [n1, n2]
//         }
//         _ -> [stone * 2024]
//       }
//     })
//   case i {
//     1 -> stones
//     _ -> blink(stones, i - 1)
//   }
// }

fn parse_int(a) {
  case a |> int.parse {
    Ok(a) -> a
    _ -> panic
  }
}
