#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=oneplus3
VENDOR=oneplus

# Load extractutils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

ARROW_ROOT="$MY_DIR"/../../..

HELPER="$ARROW_ROOT"/vendor/arrow/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

if [ $# -eq 0 ]; then
  SRC=adb
else
  if [ $# -eq 1 ]; then
    SRC=$1
  else
    echo "$0: bad number of arguments"
    echo ""
    echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
    echo ""
    echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
    echo "the device using adb pull."
    exit 1
  fi
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$ARROW_ROOT"

extract "$MY_DIR"/proprietary-files-qc.txt "$SRC"
extract "$MY_DIR"/proprietary-files-qc-perf.txt "$SRC"
extract "$MY_DIR"/proprietary-files.txt "$SRC"

"$MY_DIR"/setup-makefiles.sh

BLOB_ROOT="$ARROW_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

CAMERA_HAL="$BLOB_ROOT"/vendor/lib/hw/camera.msm8996.so

sed -i \
    -e 's/_ZN7qcamera17QCameraParameters16setQuadraCfaModeEjb/_ZN7qcamera17QCameraParameters16setQuadraCfaModSHIM/' \
    -e 's/_ZN7qcamera17QCameraParameters12setQuadraCfaERKS0_/_ZN7qcamera17QCameraParameters12setQuadraCfaERSHIM/' \
    -e 's/_ZN7qcamera17QCameraParameters12getQuadraCfaEv/_ZN7qcamera17QCameraParameters12getQuadraCSHIM/' \
    -e 's/_ZN7qcamera15isOneplusCameraEv/_ZN7qcamera15isOneplusCameSHIM/' \
    -e 's/_ZN7qcamera17QCameraParameters15is3p8spLowLightEv/_ZN7qcamera17QCameraParameters15is3p8spLowLigSHIM/' \
    -e 's/_ZN7qcamera17QCameraParameters21handleSuperResoultionEv/_ZN7qcamera17QCameraParameters21handleSuperResoultiSHIM/' \
    -e 's/_ZN7qcamera17QCameraParameters17isSuperResoultionEv/_ZN7qcamera17QCameraParameters17isSuperResoultiSHIM/' \
    "$CAMERA_HAL"

patchelf --replace-needed android.hardware.gnss@1.0.so android.hardware.gnss@1.0-v27.so $BLOB_ROOT/vendor/lib64/vendor.qti.gnss@1.0_vendor.so
patchelf --replace-needed android.hardware.gnss@1.0.so android.hardware.gnss@1.0-v27.so $BLOB_ROOT/lib64/vendor.qti.gnss@1.0.so
