/**
 * PSGC Address Picker Utility
 * Uses the PSGC API (https://psgc.gitlab.io/api/) to provide
 * cascading dropdowns: Region → Province → City/Municipality → Barangay + Street input
 *
 * Usage:
 *   PsgcAddress.init('prefix_')
 *   - expects DOM elements:
 *       #prefix_region   (select)
 *       #prefix_province (select)
 *       #prefix_city     (select)
 *       #prefix_barangay (select)
 *       #prefix_street   (text input, optional)
 *       #prefix_address  (hidden input — auto-updated)
 *
 *   PsgcAddress.getValue('prefix_') => combined address string
 *   PsgcAddress.setValue('prefix_', addressString) => attempts to restore selections
 *
 * Each prefix gets its own independent instance; calling init() again for the
 * same prefix is safe — event listeners are NOT duplicated.
 */

(function (window) {
    'use strict';

    var BASE = 'https://psgc.gitlab.io/api';

    // Per-prefix state tracking (keyed by prefix string)
    var _instances = {};

    function fetchJson(url) {
        return fetch(url).then(function (res) {
            if (!res.ok) throw new Error('PSGC fetch failed: ' + url);
            return res.json();
        });
    }

    function getEl(prefix, suffix) {
        return document.getElementById(prefix + suffix);
    }

    function resetSelect(sel, placeholder) {
        if (!sel) return;
        sel.innerHTML = '<option value="">' + placeholder + '</option>';
        sel.disabled = true;
    }

    function fillSelect(sel, items) {
        if (!sel || !items) return;
        var sorted = items.slice().sort(function (a, b) {
            return (a.name || '').localeCompare(b.name || '');
        });
        sorted.forEach(function (item) {
            var opt = document.createElement('option');
            opt.value = item.code;
            opt.textContent = item.name;
            sel.appendChild(opt);
        });
        sel.disabled = false;
    }

    function updateHidden(prefix) {
        var region   = getEl(prefix, 'region');
        var province = getEl(prefix, 'province');
        var city     = getEl(prefix, 'city');
        var barangay = getEl(prefix, 'barangay');
        var street   = getEl(prefix, 'street');
        var hidden   = getEl(prefix, 'address');

        var parts = [];
        var streetVal = street && street.value ? street.value.trim() : '';
        if (streetVal) parts.push(streetVal);
        if (barangay && barangay.value) parts.push(barangay.options[barangay.selectedIndex].text);
        if (city && city.value) parts.push(city.options[city.selectedIndex].text);
        if (province && province.value && province.value !== 'N/A') {
            parts.push(province.options[province.selectedIndex].text);
        }
        if (region && region.value) parts.push(region.options[region.selectedIndex].text);

        if (hidden) hidden.value = parts.join(', ');
    }

    function initPsgcAddress(prefix) {
        // Guard: only initialize once per prefix per page lifetime
        if (_instances[prefix]) return;
        _instances[prefix] = true;

        var regionSel   = getEl(prefix, 'region');
        var provinceSel = getEl(prefix, 'province');
        var citySel     = getEl(prefix, 'city');
        var barangaySel = getEl(prefix, 'barangay');
        var streetEl    = getEl(prefix, 'street');

        if (!regionSel) {
            delete _instances[prefix]; // allow retry if DOM is not ready
            return;
        }

        // Load regions
        fetchJson(BASE + '/regions/').then(function (regions) {
            fillSelect(regionSel, regions);
        }).catch(function (e) {
            console.error('PSGC: failed to load regions', e);
        });

        regionSel.addEventListener('change', function () {
            var regionCode = this.value;
            resetSelect(provinceSel, 'Select Province');
            resetSelect(citySel, 'Select City/Municipality');
            resetSelect(barangaySel, 'Select Barangay');
            updateHidden(prefix);
            if (!regionCode) return;

            fetchJson(BASE + '/regions/' + regionCode + '/provinces/')
                .then(function (provinces) {
                    if (provinces && provinces.length > 0) {
                        fillSelect(provinceSel, provinces);
                    } else {
                        // NCR / special regions with no provinces — load cities directly
                        provinceSel.innerHTML = '<option value="N/A">N/A (No Province)</option>';
                        provinceSel.disabled = false;
                        return fetchJson(BASE + '/regions/' + regionCode + '/cities-municipalities/')
                            .then(function (cities) { fillSelect(citySel, cities); });
                    }
                })
                .catch(function (e) { console.error('PSGC: failed to load provinces', e); });
        });

        provinceSel.addEventListener('change', function () {
            var provCode = this.value;
            resetSelect(citySel, 'Select City/Municipality');
            resetSelect(barangaySel, 'Select Barangay');
            updateHidden(prefix);
            if (!provCode || provCode === 'N/A') return;

            fetchJson(BASE + '/provinces/' + provCode + '/cities-municipalities/')
                .then(function (cities) { fillSelect(citySel, cities); })
                .catch(function (e) { console.error('PSGC: failed to load cities', e); });
        });

        citySel.addEventListener('change', function () {
            var cityCode = this.value;
            resetSelect(barangaySel, 'Select Barangay');
            updateHidden(prefix);
            if (!cityCode) return;

            fetchJson(BASE + '/cities-municipalities/' + cityCode + '/barangays/')
                .then(function (barangays) { fillSelect(barangaySel, barangays); })
                .catch(function (e) { console.error('PSGC: failed to load barangays', e); });
        });

        barangaySel.addEventListener('change', function () { updateHidden(prefix); });

        if (streetEl) {
            streetEl.addEventListener('input', function () { updateHidden(prefix); });
        }
    }

    function getPsgcAddressValue(prefix) {
        updateHidden(prefix);
        var hidden = getEl(prefix, 'address');
        return hidden ? hidden.value : '';
    }

    /**
     * Attempts to restore dropdown selections from a saved address string.
     * Supported formats:
     *   "Street, Barangay, City, Province, Region"  (5 parts — with street)
     *   "Barangay, City, Province, Region"           (4 parts — legacy)
     */
    function setPsgcAddress(prefix, addressString) {
        if (!addressString) return;
        var parts = addressString.split(',').map(function (s) { return s.trim(); });

        var streetName, barangayName, cityName, provinceName, regionName;
        if (parts.length >= 5) {
            streetName   = parts[0];
            barangayName = parts[1];
            cityName     = parts[2];
            provinceName = parts[3];
            regionName   = parts[4];
        } else {
            streetName   = '';
            barangayName = parts[0] || '';
            cityName     = parts[1] || '';
            provinceName = parts[2] || '';
            regionName   = parts[3] || '';
        }

        // Restore street field immediately
        var streetEl = getEl(prefix, 'street');
        if (streetEl && streetName) streetEl.value = streetName;

        if (!regionName) { updateHidden(prefix); return; }

        var regionSel   = getEl(prefix, 'region');
        var provinceSel = getEl(prefix, 'province');
        var citySel     = getEl(prefix, 'city');
        var barangaySel = getEl(prefix, 'barangay');
        if (!regionSel) return;

        waitForOptions(regionSel)
            .then(function () {
                var regionOpt = findOptionByText(regionSel, regionName);
                if (!regionOpt) { updateHidden(prefix); return Promise.reject('region not found'); }

                regionSel.value = regionOpt.value;
                regionSel.dispatchEvent(new Event('change'));

                return waitForOptions(provinceSel).then(function () {
                    if (provinceName) {
                        var provOpt = findOptionByText(provinceSel, provinceName);
                        if (provOpt) {
                            provinceSel.value = provOpt.value;
                            provinceSel.dispatchEvent(new Event('change'));
                        }
                    }
                    return waitForOptions(citySel);
                }).then(function () {
                    if (cityName) {
                        var cityOpt = findOptionByText(citySel, cityName);
                        if (cityOpt) {
                            citySel.value = cityOpt.value;
                            citySel.dispatchEvent(new Event('change'));
                        }
                    }
                    return waitForOptions(barangaySel);
                }).then(function () {
                    if (barangayName) {
                        var brgyOpt = findOptionByText(barangaySel, barangayName);
                        if (brgyOpt) barangaySel.value = brgyOpt.value;
                    }
                    updateHidden(prefix);
                });
            })
            .catch(function (reason) {
                if (reason && reason !== 'region not found') console.warn('PSGC setValue error', reason);
            });
    }

    function findOptionByText(sel, text) {
        if (!text || !sel) return null;
        var tl = text.toLowerCase();
        for (var i = 0; i < sel.options.length; i++) {
            var ol = sel.options[i].text.toLowerCase();
            if (ol.includes(tl) || tl.includes(ol)) return sel.options[i];
        }
        return null;
    }

    function waitForOptions(sel, timeout) {
        timeout = timeout || 10000;
        return new Promise(function (resolve) {
            if (sel && sel.options.length > 1 && !sel.disabled) { resolve(); return; }
            var start = Date.now();
            var iv = setInterval(function () {
                if ((sel && sel.options.length > 1 && !sel.disabled) || Date.now() - start > timeout) {
                    clearInterval(iv);
                    resolve();
                }
            }, 150);
        });
    }

    /**
     * Resets the dropdown state for a given prefix so it can be re-initialized
     * (useful when the same form is reused for multiple records on one page).
     */
    function resetPsgcAddress(prefix) {
        delete _instances[prefix];
        var regionSel   = getEl(prefix, 'region');
        var provinceSel = getEl(prefix, 'province');
        var citySel     = getEl(prefix, 'city');
        var barangaySel = getEl(prefix, 'barangay');
        var streetEl    = getEl(prefix, 'street');
        var hidden      = getEl(prefix, 'address');

        // Reset all to initial state (keep existing options but deselect)
        if (regionSel)   regionSel.selectedIndex = 0;
        if (provinceSel) { resetSelect(provinceSel, 'Select Province'); }
        if (citySel)     { resetSelect(citySel, 'Select City/Municipality'); }
        if (barangaySel) { resetSelect(barangaySel, 'Select Barangay'); }
        if (streetEl)    streetEl.value = '';
        if (hidden)      hidden.value = '';
    }

    window.PsgcAddress = {
        init:     initPsgcAddress,
        getValue: getPsgcAddressValue,
        setValue: setPsgcAddress,
        reset:    resetPsgcAddress
    };

})(window);
