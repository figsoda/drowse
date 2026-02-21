use clap::Parser;

#[derive(Parser)]
#[command(version)]
struct Args;

fn main() {
    Args::parse();
    println!("Hello, world!");
}
