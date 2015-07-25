# Copyright (C) 2015 The SaberMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# BUGFIX for AOSP
# Turn all strict-aliasing warnings into errors.
# strict-aliasing has a long well known history of breaking code when allowed to pass with warnings.
# AOSP has blindly turned on strict-aliasing in various places locally throughout the source.
# This causes warnings and should be dealt with, by turning strict-aliasing off to fix the warnings,
# until AOSP gets around to fixing the warnings locally in the code.

# Warnings and errors are turned on by default if strict-aliasing is set in LOCAL_CFLAGS.  Also check for arm mode strict-aliasing.
# GCC can handle a warning level of 3 and clang a level of 2.

ifeq ($(strip $(ENABLE_STRICT_ALIASING)),true)
  ifeq ($(strip $(LOCAL_ARM_MODE)),arm)
  arm_objects_mode := $(if $(LOCAL_ARM_MODE),$(LOCAL_ARM_MODE),arm)
    ifneq ($(strip $(LOCAL_CLANG)),true)
      arm_objects_cflags := $($(LOCAL_2ND_ARCH_VAR_PREFIX)$(my_prefix)$(arm_objects_mode)_CFLAGS)
      ifneq ($(filter -fstrict-aliasing,$(arm_objects_cflags)),)
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += $(GCC_STRICT_CFLAGS)
        else
          LOCAL_CFLAGS := $(GCC_STRICT_CFLAGS)
        endif
      endif
    else
      arm_objects_cflags := $(call $(LOCAL_2ND_ARCH_VAR_PREFIX)convert-to-$(my_host)clang-flags,$(arm_objects_cflags))
      ifneq ($(filter -fstrict-aliasing,$(arm_objects_cflags)),)
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += $(CLANG_STRICT_CFLAGS)
        else
          LOCAL_CFLAGS := $(CLANG_STRICT_CFLAGS)
        endif
      endif
    endif
  endif
  ifeq ($(strip $(TARGET_ARCH)),arm64)
    ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
      ifneq ($(strip $(LOCAL_CLANG)),true)
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += $(GCC_STRICT_CFLAGS)
        else
          LOCAL_CFLAGS := $(GCC_STRICT_CFLAGS)
        endif
      else
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += $(CLANG_STRICT_CFLAGS)
        else
          LOCAL_CFLAGS := $(CLANG_STRICT_CFLAGS)
        endif
      endif
    endif
  endif
else
  LOCAL_CFLAGS += -fno-strict-aliasing
endif

ifneq ($(strip $(TARGET_ARCH)),arm64)

  # Check for local cflags.
  ifneq ($(strip $(ENABLE_STRICT_ALIASING)),true)
    ifeq (1,$(words $(filter -fstrict-aliasing,$(LOCAL_CFLAGS))))
      ifneq ($(strip $(LOCAL_CLANG)),true)
        LOCAL_CFLAGS += $(GCC_STRICT_CFLAGS)
      else
        LOCAL_CFLAGS += $(CLANG_STRICT_CFLAGS)
      endif
    endif
  endif
endif
ifeq ($(strip $(ENABLE_STRICT_ALIASING)),true)
  ifeq (1,$(words $(filter $(LOCAL_DISABLE_STRICT_ALIASING),$(LOCAL_MODULE))))
      LOCAL_CFLAGS += -fno-strict-aliasing
  endif
endif
