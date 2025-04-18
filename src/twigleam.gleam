import gleam/list
import gleam/string
import twigleam/lexer

pub fn tokenise(input: String) -> List(lexer.Token) {
  do_lex(string.to_graphemes(input), "", [])
}

fn do_lex(input: List(String), buffer: String, accum: List(lexer.Token)) {
  case input {
    [] ->
      case buffer {
        "" -> list.reverse([lexer.EOF, ..accum])
        _ -> list.reverse([lexer.EOF, lexer.Text(buffer), ..accum])
      }

    ["{", "{", ..rest] ->
      do_lex(rest, "", [lexer.VarStart, lexer.Text(buffer), ..accum])
    ["}", "}", ..rest] ->
      do_lex(rest, "", [
        lexer.VarEnd,
        lexer.Name(buffer |> string.trim),
        ..accum
      ])
    ["{", "%", ..rest] ->
      do_lex(rest, "", [
        lexer.BlockStart,
        lexer.Name(buffer |> string.trim),
        ..accum
      ])
    ["%", "}", ..rest] -> do_lex(rest, buffer, [lexer.BlockEnd, ..accum])
    [ch, ..chars] -> do_lex(chars, buffer <> ch, accum)
  }
}
