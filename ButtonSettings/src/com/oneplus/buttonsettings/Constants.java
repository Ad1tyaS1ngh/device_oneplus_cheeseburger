/*
 * Copyright (C) 2016 The CyanogenMod Project
 *           (C) 2017-2020 The LineageOS Project
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

import java.util.HashMap;
import java.util.Map;

public class Constants {

    // Preference keys
    public static final String BUTTON_SWAP_KEY = "button_swap";

    // Nodes
    public static final String BUTTON_SWAP_PATH = "/proc/s1302/key_rep";

    // Holds <preference_key> -> <proc_node> mapping
    public static final Map<String, SwitchPreferenceBackend> sBackendsMap = new HashMap<>();

    static {
        sBackendsMap.put(BUTTON_SWAP_KEY,
                new SwitchPreferenceBackend(BUTTON_SWAP_PATH));
    }
}
