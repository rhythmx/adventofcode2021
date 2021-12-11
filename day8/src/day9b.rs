use std::fs::File;
use std::path::Path;
use std::io::prelude::*;

#[derive(Debug)]
struct Pair (usize, usize);

fn find_basins(map: &Vec<Vec<u32>>, point: &Pair, basin: &mut Vec<Pair>) {
    let xdim = map[0].len();
    let ydim = map.len();

    let y = point.0;
    let x = point.1;

    // search for local minima
    let posval = map[y][x];

    if posval == 9 {
        return;
    }

    // base case it to not recurse if this node has been visited
    let thispoint = Pair(y,x);
    if basin.iter().any(|pair| pair.0 == thispoint.0 && pair.1 == thispoint.1) {
        return;
    }

    basin.push(Pair(y,x));

    // recurse to neighbors
    if x > 0 {
        find_basins(&map, &Pair(y,x-1), basin);
    }
    if x < xdim-1 {
        find_basins(&map, &Pair(y,x+1), basin);
    }
    if y > 0 {
        find_basins(&map, &Pair(y-1,x), basin);
    }
    if y < ydim-1 {
        find_basins(&map, &Pair(y+1,x), basin);
    }
}

fn main() {

    // Read in the input file
    let path = Path::new("day9.real");
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

    let mut lowpoints:  Vec<Pair> = Vec::new();

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

            let pair = Pair(y, x);

            lowpoints.push(pair);
        }
    }

    let mut basins: Vec<Vec<Pair>> = Vec::new();

    for lowpoint in &lowpoints {
        let mut basin: Vec<Pair> = Vec::new();
        find_basins(&map, lowpoint, &mut basin);
        basins.push(basin);
    }

    // descending sort by basin size
    basins.sort_by(|a,b| b.len().partial_cmp(&a.len()).unwrap());


    println!("Basins result {:?}", basins[0].len() * basins[1].len() * basins[2].len()
);


}
