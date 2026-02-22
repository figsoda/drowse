use clap::Parser;

#[derive(Parser)]
#[cfg_attr(feature = "fancy", command(version = "9.9.9+fancy"))]
#[cfg_attr(not(feature = "fancy"), command(version))]
struct Args;

fn main() {
    Args::parse();
    println!("Hello, world!");
}
