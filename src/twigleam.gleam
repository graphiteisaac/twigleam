import gleam/list
import gleam/string
import twigleam/lexer

pub fn tokenise(input: String) -> List(lexer.Token) {
  do_lex(string.to_graphemes(input), Context(StateText, "", #(0, 0)), [])
}

type LexerState {
  StateText
  StateVerbatim
  StateTag
  StateBlock
  StateComment
}

type Context {
  Context(
    state: LexerState,
    buffer: String,
    pos: #(Int, Int)
  )
}

fn do_lex(input: List(String), ctx: Context, accum: List(lexer.Token)) {
  case input {
    [] ->
      case ctx.buffer {
        "" -> list.reverse([lexer.EOF, ..accum])
        _ -> list.reverse([lexer.EOF, lexer.Text(ctx.buffer), ..accum])
      }

    ["{", "{", ..rest] ->
      do_lex(rest, ctx, [lexer.VarStart, lexer.Text(ctx.buffer), ..accum])
    ["}", "}", ..rest] ->
      do_lex(rest, ctx, [
        lexer.VarEnd,
        lexer.Name(ctx.buffer |> string.trim),
        ..accum
      ])
    ["{", "%", ..rest] -> do_lex(rest, ctx, [lexer.BlockStart, ..accum])
    ["%", "}", ..rest] ->
      do_lex(rest, ctx, [
        lexer.BlockEnd,
        lexer.Name(ctx.buffer |> string.trim),
        ..accum
      ])
    ["{", "#", ..rest] -> do_lex(rest, Context(..ctx, state: StateComment), [lexer.CommentStart, ..accum])
    ["#", "}", ..rest] ->
      do_lex(rest, Context(..ctx, state: StateText), [
        lexer.CommentEnd,
        lexer.Text(ctx.buffer |> string.trim),
        ..accum
      ])

    [ch, ..chars] -> {
      // TODO: This fails when a regular word like "or" or "and" or any other operator is used anywhere. We need to check it in / around names only.

      case string.join(input, "") {
        " or " <> _ ->
          do_lex(list.drop(input, 4), ctx, [
            lexer.Operator(lexer.Or),
            ..accum
          ])
        "==" <> _ ->
          do_lex(list.drop(input, 2), ctx, [
            lexer.Operator(lexer.IsEqual),
            ..accum
          ])
        " and " <> _ ->
          do_lex(list.drop(input, 3), ctx, [
            lexer.Operator(lexer.And),
            ..accum
          ])
        _ -> do_lex(chars, Context(..ctx, buffer: ctx.buffer <> ch), accum)
      }
    }
  }
}
