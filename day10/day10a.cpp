/* Day 10 - Syntax Scoring */

#include <iostream>
#include <fstream>
#include <ranges>
#include <string_view>
#include <deque>
#include <unordered_map>

std::unordered_map<char,char> opening_char_for =
  {
    { '}', '{' },
    { ']', '[' },
    { ')', '(' },
    { '>', '<' }
  };

std::unordered_map<char,int> score_for =
  {
    { ')', 3 },
    { ']', 57 },
    { '}', 1197 },
    { '>', 25137 }
  };

void process_line(std::string_view &line, int &total_score) {
  std::deque<char> syntax_checker;

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
          total_score += score_for[c];
          return;
        }
      }
      break;

    default:
      /* ignore all other chars */
      break;
    }
  }
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

  //
  auto lines = data
    | std::ranges::views::split('\n')
    | std::ranges::views::transform([](auto &&str) {
      return std::string_view(&*str.begin(), std::ranges::distance(str));
    });

  int total_score = 0;

  for(auto&& line : lines) {
    process_line(line, total_score);
  }

  std::cout << "Total score: " << total_score << "\n";

  return 0;
}
