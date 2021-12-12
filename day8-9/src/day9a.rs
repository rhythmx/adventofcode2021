use std::fs::File;
use std::path::Path;
use std::io::prelude::*;


#[derive(Debug)]
struct Pair (usize, usize);

fn main() {

    // Read in the input file
    let path = Path::new("day9.example");
    let mut file = match File::open(&path) {
        Err(why) => panic!("couldn't open file: {}", why),
        Ok(file) => file,
    };
    let mut s = String::new();
    match file.read_to_string(&mut s) {
        Err(why) => panic!("couldn't read file: {}", why),
        _ => ()
    };

    // Preprocess the input file into 2d array of digits
    let map : Vec<Vec<_>> = s.split("\n")
        .into_iter()
        .map(|line|
             line.chars()
             .map(|c| c.to_digit(10).unwrap() ).collect())
        .collect();

    println!("Lines: {:?}", map);

    let xdim = map[0].len();
    let ydim = map.len();

    let mut lowpoints:  Vec<usize> = Vec::new();

    for y in 0..ydim {
        for x in 0..xdim {

            // search for local minima
            let posval = map[y][x];

            if x > 0 {
                if map[y][x-1] <= posval { continue; }
            }
            if x < xdim-1 {
                if map[y][x+1] <= posval { continue; }
            }
            if y > 0 {
                if map[y-1][x] <= posval { continue; }
            }
            if y < ydim-1 {
                if map[y+1][x] <= posval { continue; }
            }

            let _pair = Pair(y, x);

            lowpoints.push(posval.try_into().unwrap()); 
        }
    }

    println!("Lowpoints {:?}", lowpoints);

    println!("Result {}", lowpoints.iter().sum::<usize>() + lowpoints.len());

}
