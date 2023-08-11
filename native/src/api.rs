// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

use flutter_rust_bridge::StreamSink;
use std::time::Duration;
use sysinfo::{CpuExt, System, SystemExt};

pub enum Platform {
    Unknown,
    Android,
    Ios,
    Windows,
    Unix,
    MacIntel,
    MacApple,
    Wasm,
}

// A function definition in Rust. Similar to Dart, the return type must always be named
// and is never inferred.
pub fn platform() -> Platform {
    // This is a macro, a special expression that expands into code. In Rust, all macros
    // end with an exclamation mark and can be invoked with all kinds of brackets (parentheses,
    // brackets and curly braces). However, certain conventions exist, for example the
    // vector macro is almost always invoked as vec![..].
    //
    // The cfg!() macro returns a boolean value based on the current compiler configuration.
    // When attached to expressions (#[cfg(..)] form), they show or hide the expression at compile time.
    // Here, however, they evaluate to runtime values, which may or may not be optimized out
    // by the compiler. A variety of configurations are demonstrated here which cover most of
    // the modern oeprating systems. Try running the Flutter application on different machines
    // and see if it matches your expected OS.
    //
    // Furthermore, in Rust, the last expression in a function is the return value and does
    // not have the trailing semicolon. This entire if-else chain forms a single expression.
    if cfg!(windows) {
        Platform::Windows
    } else if cfg!(target_os = "android") {
        Platform::Android
    } else if cfg!(target_os = "ios") {
        Platform::Ios
    } else if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
        Platform::MacApple
    } else if cfg!(target_os = "macos") {
        Platform::MacIntel
    } else if cfg!(target_family = "wasm") {
        Platform::Wasm
    } else if cfg!(unix) {
        Platform::Unix
    } else {
        Platform::Unknown
    }
}

// The convention for Rust identifiers is the snake_case,
// and they are automatically converted to camelCase on the Dart side.
pub fn rust_release_mode() -> bool {
    cfg!(not(debug_assertions))
}

pub fn hello() -> String {
    String::from("hello from rust")
}

pub fn greet(name: String) -> String {
    format!("Hello {}", name)
}

pub struct Components {
    pub cpu: String,
    pub system_name: String,
    pub kernal: String,
    pub os_version: String,
    pub host_name: String,
    pub memory: u64,
}

pub fn if_sys_info_supported() -> bool {
    System::IS_SUPPORTED
}

pub fn get_sys_info() -> Components {
    let mut sys = System::new_all();

    // First we update all information of our `System` struct.
    sys.refresh_all();
    let cpu = sys.cpus().first().unwrap().brand();

    return Components {
        cpu: cpu.to_string(),
        system_name: sys.name().unwrap().to_string(),
        kernal: sys.kernel_version().unwrap().to_string(),
        os_version: sys.os_version().unwrap().to_string(),
        host_name: sys.host_name().unwrap().to_string(),
        memory: sys.total_memory() / u64::pow(1024, 3),
    };
}

pub fn get_cpu() -> String {
    let mut sys = System::new_all();

    // First we update all information of our `System` struct.
    sys.refresh_all();
    let cpu = sys.cpus().first();

    match cpu {
        Some(e) => return format!("{}", e.brand()),
        None => return String::from("No Data"),
    }
}

pub fn stream_cpu_usage(sink: StreamSink<Vec<f32>>) {
    let mut sys = System::new();

    loop {
        sys.refresh_cpu(); // Refreshing CPU information.
        let mut cpu_usage_list: Vec<f32> = vec![];

        for cpu in sys.cpus() {
            cpu_usage_list.push(cpu.cpu_usage());
        }

        sink.add(cpu_usage_list);
        // Sleeping to let time for the system to run for long
        // enough to have useful information.
        std::thread::sleep(Duration::new(2, 0));
    }
}

pub enum Operator {
    Plus,
    Minus,
    Multiply,
    Divide,
}

pub fn calculate(first_value: i32, second_value: i32, operator: Operator) -> i32 {
    match operator {
        Operator::Plus => first_value + second_value,
        Operator::Minus => first_value - second_value,
        Operator::Multiply => first_value * second_value,
        Operator::Divide => first_value / second_value,
        _ => 0,
    }
}
