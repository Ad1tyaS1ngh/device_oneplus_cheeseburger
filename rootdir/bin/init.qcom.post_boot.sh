#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`

# disable thermal bcl hotplug to switch governor
echo 0 > /sys/module/msm_thermal/core_control/enabled

# online CPU0
echo 1 > /sys/devices/system/cpu/cpu0/online
# configure governor settings for little cluster
echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
echo 20000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us
# online CPU4
echo 1 > /sys/devices/system/cpu/cpu4/online
# configure governor settings for big cluster
echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 500 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
echo 20000 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us

# bring all cores online
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online

# Setup power retention
echo N > /sys/module/lpm_levels/system/pwr/cpu0/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu1/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu2/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/cpu3/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu4/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu5/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu6/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/cpu7/ret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-dynret/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-ret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-dynret/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-ret/idle_enabled

# re-enable thermal and BCL hotplug
echo 1 > /sys/module/msm_thermal/core_control/enabled

# Enable bus-dcvs
for cpubw in /sys/class/devfreq/*qcom,cpubw*
do
    echo "bw_hwmon" > $cpubw/governor
    echo 50 > $cpubw/polling_interval
    echo 1525 > $cpubw/min_freq
    echo "3143 5859 11863 13763" > $cpubw/bw_hwmon/mbps_zones
    echo 4 > $cpubw/bw_hwmon/sample_ms
    echo 34 > $cpubw/bw_hwmon/io_percent
    echo 20 > $cpubw/bw_hwmon/hist_memory
    echo 10 > $cpubw/bw_hwmon/hyst_length
    echo 0 > $cpubw/bw_hwmon/low_power_ceil_mbps
    echo 34 > $cpubw/bw_hwmon/low_power_io_percent
    echo 20 > $cpubw/bw_hwmon/low_power_delay
    echo 0 > $cpubw/bw_hwmon/guard_band_mbps
    echo 250 > $cpubw/bw_hwmon/up_scale
    echo 1600 > $cpubw/bw_hwmon/idle_mbps
done

for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
do
    echo "mem_latency" > $memlat/governor
    echo 10 > $memlat/polling_interval
    echo 400 > $memlat/mem_latency/ratio_ceil
done

echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

# cpuset parameters
echo 0-7 > /dev/cpuset/top-app/cpus
echo 0-3,6-7 > /dev/cpuset/foreground/cpus
echo 0-1 > /dev/cpuset/background/cpus
echo 0-3 > /dev/cpuset/system-background/cpus
echo 0-3 > /dev/cpuset/restricted/cpus

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

# Enable PowerHAL hint processing
setprop vendor.powerhal.init 1

setprop vendor.post_boot.parsed 1
