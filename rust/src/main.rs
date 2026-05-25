use api::cpu::Cpu;

pub mod api;

fn main() {
    let mut cpu = Cpu::new();
    cpu.fetch_data();
    println!("{:#?}", cpu);
}
