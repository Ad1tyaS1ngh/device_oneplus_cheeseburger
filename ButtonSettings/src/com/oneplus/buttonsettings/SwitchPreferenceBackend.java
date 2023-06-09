/*
 * Copyright (C) 2018-2020 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.oneplus.buttonsettings;

public class SwitchPreferenceBackend {

    private String[] mPaths;
    private Boolean mValid;

    public SwitchPreferenceBackend(String[] paths) {
        mPaths = paths;
        updateValidity();
    }

    public SwitchPreferenceBackend(String path) {
        this(new String[]{path});
    }

    public void setValue(Boolean value) {
        for (String path : mPaths) {
            if (!FileUtils.isFileWritable(path)) {
                continue;
            }

            FileUtils.writeLine(path, value ? "1" : "0");
        }
    }

    public Boolean getValue() {
        Boolean value = false;
        for (String path : mPaths) {
            if (!FileUtils.isFileReadable(path)) {
                continue;
            }

            if (Integer.parseInt(FileUtils.readOneLine(path)) == 1) {
                value = true;
            }
        }
        return value;
    }

    public Boolean isValid() {
        return mValid;
    }

    private void updateValidity() {
        Boolean valid = false;

        /*
         * Only one path might be available on a specific device,
         * but we need to try multiple to handle multiple kernel drivers.
         * Cache the validity to avoid slow fragment rendering times.
         */
        for (String path : mPaths) {
            if (FileUtils.isFileReadable(path) && FileUtils.isFileWritable(path)) {
                valid = true;
                break;
            }
        }

        mValid = valid;
    }
}
