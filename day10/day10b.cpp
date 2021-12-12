/* Day 10 - Syntax Scoring */

#include <iostream>
#include <fstream>
#include <ranges>
#include <string_view>
#include <deque>
#include <unordered_map>
#include <algorithm>
#include <functional>

std::unordered_map<char,char> closing_char_for =
  {
    { '{', '}' },
    { '[', ']' },
    { '(', ')' },
    { '<', '>' }
  };

std::unordered_map<char,char> opening_char_for =
  {
    { '}', '{' },
    { ']', '[' },
    { ')', '(' },
    { '>', '<' }
  };

std::unordered_map<char,unsigned long int> score_for =
  {
    { ')', 1 },
    { ']', 2 },
    { '}', 3 },
    { '>', 4 }
  };

unsigned long int process_line(std::string_view &line) {
  std::deque<char> syntax_checker;

  unsigned long int line_score = 0;

  std::cout << "Line: " << line << "\n";

  /* When a closing chunk character is encountered, the chunk are balanced iff
     the top of the check stack is the corresponding chunk opening
     character. Return true if balanced, else false and update total_score. */

  for(auto c : line) {
    switch(c) {

    case '{': case '(': case '[': case '<':
      /* Opening chars */
      syntax_checker.push_back(c);
      break;

    case '}': case ')': case ']': case '>':
      {
        /* Closing chars */
        char expect = opening_char_for[c];
        char actual = syntax_checker.back();
        syntax_checker.pop_back();
        if(actual != expect) {
          std::cout << "Expected " << expect << ", but found " << actual << " instead.\n";
          return 0; /* skip rest of line */
        }
      }
      break;

    default:
      /* ignore all other chars */
      break;
    }
  }

  if(syntax_checker.size() > 0)
    std::cout << "Line requires completion: ";

  /* Line contains no syntax error but may be incomplete */
  while(syntax_checker.size() > 0) {
    char missing = syntax_checker.back();
    syntax_checker.pop_back();
    std::cout << closing_char_for[missing];
    line_score *= 5;
    line_score += score_for[closing_char_for[missing]];
  }

  std::cout << " Score: " << line_score << "\n";

  return line_score;
}

int main() {
  // Read in input
  std::ifstream file;
  file.open("day10.real");
  if(!file.is_open()) {
    throw "file not open";
  }
  std::string data;
  while(!file.eof()) {
    char rdbuf[4096];
    file.read(rdbuf,sizeof(rdbuf));
    data.append(rdbuf,file.gcount());
  }

  auto line_scores_view = data
    | std::ranges::views::split('\n')
    | std::ranges::views::transform([](auto &&str) {return std::string_view(&*str.begin(), std::ranges::distance(str));})
    | std::ranges::views::transform([](auto &&line) {return process_line(line);})
    | std::ranges::views::filter([](auto &&score) {return score > 0;});

  std::vector line_scores(line_scores_view.begin(), line_scores_view.end());

  std::sort(line_scores.begin(), line_scores.end());

  for(auto score : line_scores) {
    std::cout << "Line score: " << score << "\n";
  }

  unsigned long int selected_score = line_scores[(line_scores.size())/2];

  std::cout << "Selected score: " << selected_score << "\n";

  return 0;
}
