#!/bin/bash
export kernel=LGH990-jahlex
export outdir=/home/alex/out
export makeopts="-j$(nproc)"
export zImagePath="build/arch/arm64/boot/Image.gz-dtb"
export KBUILD_BUILD_USER=Jahlex
export KBUILD_BUILD_HOST=Jahlex
export CROSS_COMPILE=/home/alex/gcc-linaro-7.1.1-2017.08-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
export ARCH=arm64
export shouldclean="1"

export version=0.0
export RDIR=$(pwd)
export KERNEL_COMPRESSION_SUFFIX="gz"

function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        rm -rf build
        rm -rf zip/modules
        rm -f zip/Image.gz-dtb
    fi
    export deviceconfig="current_elsa_jahlex_defconfig"
    export device=$1
    mkdir -p build
    mkdir -p zip/modules

    make -C ${RDIR} O=build ${makeopts} ${deviceconfig}
    make -C ${RDIR} O=build ${makeopts}

    if [ -a ${zImagePath} ] ; then
        cp ${zImagePath} zip/Image.gz-dtb
        find -name '*.ko' -exec cp -av {} zip/modules/ \;
        cd zip
        zip -q -r ${kernel}-${device}-${version}.zip anykernel.sh META-INF tools modules Image.gz-dtb setfiles.conf ramdisk patch
    else
        echo -e "\n\e[31m***** Build Failed *****\e[0m\n"
    fi

    if ! [ -d ${outdir} ] ; then
        mkdir ${outdir}
    fi

    if [ -a ${kernel}-${device}-${version}.zip ] ; then
        mv -v ${kernel}-${device}-${version}.zip ${outdir}
    fi

    cd ${RDIR}

	rm -rf zip/modules
    rm -f zip/Image.gz-dtb

}

build "LGH990"