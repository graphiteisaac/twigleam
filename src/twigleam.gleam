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
    ["{", "%", ..rest] -> do_lex(rest, "", [lexer.BlockStart, ..accum])
    ["%", "}", ..rest] ->
      do_lex(rest, "", [
        lexer.BlockEnd,
        lexer.Name(buffer |> string.trim),
        ..accum
      ])
    ["{", "#", ..rest] -> do_lex(rest, "", [lexer.CommentStart, ..accum])
    ["#", "}", ..rest] ->
      do_lex(rest, "", [
        lexer.CommentEnd,
        lexer.Text(buffer |> string.trim),
        ..accum
      ])

    [ch, ..chars] -> {
      // TODO: This fails when a regular word like "or" or "and" or any other operator is used anywhere. We need to check it in / around names only.

      case string.join(input, "") {
        " or " <> _ ->
          do_lex(list.drop(input, 4), buffer, [
            lexer.Operator(lexer.Or),
            ..accum
          ])
        "==" <> _ ->
          do_lex(list.drop(input, 2), buffer, [
            lexer.Operator(lexer.IsEqual),
            ..accum
          ])
        " and " <> _ ->
          do_lex(list.drop(input, 3), buffer, [
            lexer.Operator(lexer.And),
            ..accum
          ])
        _ -> do_lex(chars, buffer <> ch, accum)
      }
    }
  }
}
