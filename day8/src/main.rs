use std::fs::File;
use std::path::Path;
use std::io::prelude::*;

use regex::Regex;

// ... my first ever non-trivial rust program. be gentle

// Example Input Line (any number of lines):

// acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf

// The first 10 groupings are signal patterns

// The last 4 groupings are a 4 digit outputs

#[derive(Debug)]
struct SignalPattern(Vec<char>);

#[derive(Debug)]
struct SignalList(Vec<SignalPattern>);

#[derive(Debug)]
struct OutputPattern(Vec<char>);

#[derive(Debug)]
struct OutputList(Vec<OutputPattern>);

#[derive(Debug)]
struct Input(SignalList,OutputList);

#[derive(Debug)]
struct InputList(Vec<Input>);

fn parse_line(line: &str) -> Option<Input> {

    if line.len() == 0 {
        return None;
    }

    // Parse whole input line: <signals> | <outputs>
    let re = Regex::new(r#"\s*\|\s*"#).unwrap();
    let mut signals_and_outputs = re.split(line);

    // parse signals portion into SignalPattern char vecs
    let signals_str = signals_and_outputs.next().unwrap();
    let signals: Vec<_> = signals_str
        .split_whitespace()
        .into_iter()
        .map(|signal_str| SignalPattern(signal_str.chars().collect()))
        .collect();

    let outputs_str = signals_and_outputs.next().unwrap();
    let outputs: Vec<_> = outputs_str
        .split_whitespace()
        .into_iter()
        .map(|output_str| OutputPattern(output_str.chars().collect()))
        .collect();

    return Some(Input(SignalList(signals),OutputList(outputs)));
}

fn count_1478_appearances(inputs: InputList) -> u32 {
    let mut count: u32 = 0;

    for input in inputs.0 {
        for output in input.1.0 {
            count += match output.0.len() {
                2 => 1,
                4 => 1,
                3 => 1,
                7 => 1,
                _ => 0
            };
            //println!("Signal {:?}", signal);
        }
    }


    return count;
}

fn main() {

    // Read in the input file
    let path = Path::new("day8.real");
    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open file: {}", why),
        Ok(file) => file,
    };
    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(why) => panic!("couldn't read file: {}", why),
        _ => ()
    };

    // Preprocess the input file
    let lines = s.split("\n");
    let inputs_vec: Vec<Input> = lines
        .into_iter()
        .filter_map(|line| parse_line(line))
        .collect();
    let inputs = InputList(inputs_vec);

    println!("Inputs: {:?}", inputs);

    let count = count_1478_appearances(inputs);

    println!("Count is {}", count);

}
