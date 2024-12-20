import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile.{read}

// import gleam/yielder

const example = "2333133121414131402"

pub type Space {
  File(id: Int, size: Int)
  Empty(size: Int)
}

pub fn main() {
  let assert 1928 = part1(example)
  let assert 2858 = part2(example)
  let assert Ok(input) = read(from: "./input/day9.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(_, blocks) = input |> parse_input
  blocks |> compact |> checksum
}

pub fn part2(input) {
  let #(id, blocks) = input |> parse_input
  blocks |> compact2(id) |> checksum
}

fn parse_input(input) {
  let #(i, blocks) =
    input
    |> string.trim()
    |> string.to_graphemes
    |> list.map_fold(0, fn(i, a) {
      let size = case int.parse(a) {
        Ok(size) -> size
        Error(_) -> panic
      }
      let block = case i % 2 {
        0 -> File(i / 2, size)
        _ -> Empty(size)
      }
      #(i + 1, block)
    })
  #(i / 2, blocks |> deque.from_list)
}

fn compact(blocks: Deque(Space)) {
  // blocks |> deque.to_list |> debug
  case first_empty(blocks, []) {
    Ok(#(free_size, left_blocks, rest)) -> {
      let #(file_size, file_id, rest) = last_file(rest)
      let rest = case int.compare(free_size, file_size) {
        order.Lt ->
          rest
          |> deque.push_front(File(file_id, free_size))
          |> deque.push_back(File(file_id, file_size - free_size))
        order.Eq ->
          rest
          |> deque.push_front(File(file_id, free_size))
        order.Gt ->
          rest
          |> deque.push_front(Empty(free_size - file_size))
          |> deque.push_front(File(file_id, file_size))
      }
      // trim free spaces from end
      let #(file_size, file_id, rest) = last_file(rest)
      let rest = rest |> deque.push_back(File(file_id, file_size))
      left_blocks |> list.append(compact(rest))
    }
    Error(_) -> blocks |> deque.to_list
  }
}

fn first_empty(blocks: Deque(Space), compacted_blocks: List(Space)) {
  blocks
  |> deque.pop_front
  |> result.try(fn(x) {
    case x {
      #(Empty(..) as block, rest) ->
        Ok(#(block.size, compacted_blocks |> list.reverse, rest))
      #(File(..) as block, rest) ->
        first_empty(rest, [block, ..compacted_blocks])
    }
  })
}

fn last_file(blocks: Deque(Space)) {
  case blocks |> deque.pop_back {
    Ok(#(File(..) as block, rest)) -> #(block.size, block.id, rest)
    Ok(#(Empty(..), rest)) -> last_file(rest)
    Error(_) -> panic
  }
}

fn checksum(blocks: List(Space)) {
  checksum_loop(blocks, 0)
}

fn checksum_loop(blocks: List(Space), index: Int) {
  case blocks {
    [hd, ..rest] ->
      case hd {
        File(id, size) -> {
          let block_sum = case size {
            0 -> 0
            _ ->
              list.range(index, index + size - 1)
              |> list.map(int.multiply(_, id))
              |> int.sum
          }
          block_sum + checksum_loop(rest, index + size)
        }
        Empty(size) -> checksum_loop(rest, index + size)
      }
    [] -> 0
  }
}

// fn debug(blocks: List(Space)) {
//   io.debug(
//     blocks
//     |> list.map(fn(block) {
//       case block {
//         File(id, size) ->
//           yielder.repeat(id |> int.to_string)
//           |> yielder.take(size)
//           |> yielder.fold("", fn(acc, x) { acc <> x })
//         Empty(size) ->
//           yielder.repeat(".")
//           |> yielder.take(size)
//           |> yielder.fold("", fn(acc, x) { acc <> x })
//       }
//     })
//     |> string.join(""),
//   )
//   blocks
// }

fn compact2(blocks: Deque(Space), id: Int) {
  case id {
    0 -> blocks |> deque.to_list
    _ -> {
      let #(id, size, left, right) = last_id(blocks, id, [])
      compact2(first_fit(left, id, size), id - 1)
      |> list.append(right)
    }
  }
}

fn last_id(blocks: Deque(Space), id: Int, right: List(Space)) {
  case blocks |> deque.pop_back {
    Ok(#(File(..) as file, left)) if file.id == id -> #(
      file.id,
      file.size,
      left,
      right,
    )
    Ok(#(space, rest)) -> last_id(rest, id, [space, ..right])
    Error(Nil) -> panic
  }
}

fn first_fit(blocks: Deque(Space), id: Int, size: Int) {
  case blocks |> deque.pop_front {
    Ok(#(Empty(..) as empty, rest)) if empty.size >= size ->
      case int.compare(empty.size, size) {
        order.Gt ->
          rest
          |> deque.push_front(Empty(empty.size - size))
          |> deque.push_front(File(id, size))
          |> deque.push_back(Empty(size))
        order.Eq ->
          rest
          |> deque.push_front(File(id, size))
          |> deque.push_back(Empty(size))
        _ -> panic
      }
    Ok(#(space, rest)) -> first_fit(rest, id, size) |> deque.push_front(space)
    Error(Nil) -> deque.from_list([File(id, size)])
  }
}
