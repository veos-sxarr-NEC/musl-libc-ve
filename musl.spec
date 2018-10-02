%define _unpackaged_files_terminate_build 0
Name:		musl-libc-ve
Version:	1.1.14
Release:	10%{?dist}
Group:		System/Libraries
Summary:	musl-libc library ported for VE
#Group:
License:	MIT
#URL:
Source0:	musl-libc-ve-1.1.14.tar.gz
Vendor:		NEC Corporation
BuildRequires:	vedebuginfo

%description
musl libc is a new standard library to power a new generation of Linux-based
devices. musl is lightweight, fast, simple, free, and strives to be correct in
the sense of standards-conformance and safety.
musl is an alternative to glibc, eglibc, uClibc, dietlibc, and klibc.

%define _prefix /opt/nec/ve/musl
%define _libdir /opt/nec/ve/musl/lib
%define __strip /opt/nec/ve/bin/nstrip
%define _exec_prefix /opt/nec/ve
%global __debug_install_post /opt/nec/ve/libexec/find-debuginfo.sh %{nil}

%package devel
Summary: Development files for musl-libc
Group: Development/C
Requires: %name = %version-%release
Provides: %name-gcc = %version-%release

%description devel
Development files and headers for %name.

%prep
%setup -q

%build
./configure --target=ve --exec-prefix=%{_exec_prefix} --prefix=%{_prefix} --syslibdir=%{_libdir} --disable-optimize CFLAGS="-g -O0 -mno-vector -mno-vector-memcpy -fcfi-sections=debug_frame" LDFLAGS="-Wl,--build-id -Wl,-z,max-page-size=0x200000"
make ARCH=ve -j 4

%install
install -m 0755 -d %{buildroot}/etc/%{_prefix}
make DESTDIR=%{buildroot} install ARCH=ve

%files
%{_libdir}/*.so*
%{_exec_prefix}/bin/musl-ncc
%config(noreplace) /etc/%{_prefix}/ld-musl-ve.path
%config(noreplace) /etc/%{_prefix}/musl-ncc.cf

%files devel
%{_includedir}/*
%{_libdir}/*.a
%{_libdir}/*.o

%changelog
* Thu Apr 13 2017 NEC Corporation 1.1.14-1
- Added support to build musl-libc for VE architecture
