import gleeunit
import gleeunit/should
import twigleam
import twigleam/lexer

pub fn main() {
  gleeunit.main()
}

pub fn lex_trivial_text_test() {
  "Hello!"
  |> twigleam.tokenise
  |> should.equal([lexer.Text("Hello!"), lexer.EOF])
}

pub fn lex_tag_test() {
  "Hello {{ name }}"
  |> twigleam.tokenise
  |> should.equal([
    lexer.Text("Hello "),
    lexer.VarStart,
    lexer.Name("name"),
    lexer.VarEnd,
    lexer.EOF,
  ])
}

pub fn lex_block_test() {
  "{% block a %}{% endblock %}"
  |> twigleam.tokenise
  |> should.equal([
    lexer.BlockStart,
    lexer.Name("block a"),
    lexer.BlockEnd,
    lexer.BlockStart,
    lexer.Name("endblock"),
    lexer.BlockEnd,
    lexer.EOF,
  ])
}

pub fn lex_comment_test() {
  "{# This isn't something you need to worry about. #}"
  |> twigleam.tokenise
  |> should.equal([
    lexer.CommentStart,
    lexer.Text("This isn't something you need to worry about."),
    lexer.CommentEnd,
    lexer.EOF,
  ])
}
