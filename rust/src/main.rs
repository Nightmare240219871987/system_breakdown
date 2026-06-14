mod api;

use api::ram::Ram;

fn main() {
    let mut ram = Ram::new();
    ram.fetch_data();
    println!("{:#?}", ram.ram_type);
}
