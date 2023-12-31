use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_platform(port_: i64) {
    wire_platform_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_rust_release_mode(port_: i64) {
    wire_rust_release_mode_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_hello(port_: i64) {
    wire_hello_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_greet(port_: i64, name: *mut wire_uint_8_list) {
    wire_greet_impl(port_, name)
}

#[no_mangle]
pub extern "C" fn wire_if_sys_info_supported(port_: i64) {
    wire_if_sys_info_supported_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_sys_info(port_: i64) {
    wire_get_sys_info_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_cpu(port_: i64) {
    wire_get_cpu_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_stream_cpu_usage(port_: i64) {
    wire_stream_cpu_usage_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_calculate(port_: i64, first_value: i32, second_value: i32, operator: i32) {
    wire_calculate_impl(port_, first_value, second_value, operator)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
