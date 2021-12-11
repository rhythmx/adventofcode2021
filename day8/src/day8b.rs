use std::fs::File;
use std::path::Path;
use std::io::prelude::*;

use std::collections::HashSet;
use std::collections::HashMap;

use regex::Regex;


// Example Input Line (any number of lines):

// acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf

// The first 10 groupings are signal patterns

// The last 4 groupings are a 4 digit outputs

type SignalPattern = HashSet<char>;
type SignalList = Vec<SignalPattern>;
type OutputPattern = HashSet<char>;
type OutputList = Vec<OutputPattern>;
#[derive(Debug)]
struct Input {signals: SignalList, outputs: OutputList}
type InputList = Vec<Input>;

type SignalMap = HashMap<u8,SignalPattern>;

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
        .map(|signal_str| signal_str.chars().collect())
        .collect();

    let outputs_str = signals_and_outputs.next().unwrap();
    let outputs: Vec<_> = outputs_str
        .split_whitespace()
        .into_iter()
        .map(|output_str| output_str.chars().collect())
        .collect();

    return Some(Input {signals: signals, outputs: outputs});
}

fn intersection_size(sig1: &SignalPattern, sig2: &SignalPattern) -> usize {
    let map: HashSet<_> = sig1.intersection(&sig2).collect();
    return map.len();
}

fn checknum(signalmap: &SignalMap, signals: &SignalList, len: usize, int_one: usize, int_seven: usize, int_four: usize) -> SignalPattern {
    return signals
        .iter()
        .find(|signal|
             signal.len() == len &&
             intersection_size(&signal, signalmap.get(&1).unwrap()) == int_one &&
             intersection_size(&signal, signalmap.get(&7).unwrap()) == int_seven &&
             intersection_size(&signal, signalmap.get(&4).unwrap()) == int_four
        ).unwrap().clone();
}

fn deduce_signals(signals: SignalList) -> SignalMap {
    let mut signalmap: SignalMap = HashMap::new();

    // Deduce the numbers with unique segment counts
    signalmap.insert(1,signals.iter().cloned().find(|signal| signal.len() == 2).unwrap());
    signalmap.insert(7,signals.iter().cloned().find(|signal| signal.len() == 3).unwrap());
    signalmap.insert(4,signals.iter().cloned().find(|signal| signal.len() == 4).unwrap());
    signalmap.insert(8,signals.iter().cloned().find(|signal| signal.len() == 7).unwrap());

    // Deduce the numbers with non-unique segment counts from the others
    signalmap.insert(2,checknum(&signalmap,&signals,5,1,2,2));
    signalmap.insert(3,checknum(&signalmap,&signals,5,2,3,3));
    signalmap.insert(5,checknum(&signalmap,&signals,5,1,2,3));
    signalmap.insert(9,checknum(&signalmap,&signals,6,2,3,4));
    signalmap.insert(6,checknum(&signalmap,&signals,6,1,2,3));
    signalmap.insert(0,checknum(&signalmap,&signals,6,2,3,3));

    return signalmap;
}

fn lookup_num(m: &SignalMap, o: &OutputPattern) -> u32 {
    for n in 0..10 {
        if m.get(&n).unwrap() == o {
            return n.into();
        }
    }
    println!(" M {:?} -- O {:?} ", m, o);
    println!("FAIL");
    return 99999;
}

fn main() {

    // Read in the input file
    let path = Path::new("day8.example");
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
    let inputs_vec: Vec<_> = lines
        .into_iter()
        .filter_map(|line| parse_line(line))
        .collect();
    let inputs: InputList = inputs_vec;

    let mut sum = 0;

    for input in inputs {
        let rosetta = deduce_signals(input.signals);
        let output = lookup_num(&rosetta, &input.outputs[0])*1000 +
            lookup_num(&rosetta, &input.outputs[1])*100 +
            lookup_num(&rosetta, &input.outputs[2])*10 +
            lookup_num(&rosetta, &input.outputs[3])*1;
        sum += output;
    }

    println!("Sum {}", sum);
}
