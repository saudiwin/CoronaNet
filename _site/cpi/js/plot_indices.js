var keys = {"Business Restrictions": {"name": "Business Restrictions", "file": "data/biz_wide.csv", "color": "#1f77b4"},
                            "Health Resorces": {"name": "Health Resorces", "file": "data/health_resources_wide.csv", "color": "#2ca02c"},
                            "Health Monitoring": {"name": "Health Monitoring", "file": "data/health_monitoring_wide.csv", "color": "#d62728"},
                            "Masks": {"name": "Masks", "file": "data/masks_wide.csv", "color": "#1f77b4"},
                            "Social Distancing": {"name": "Social Distancing", "file": "data/social_distancing_wide.csv", "color": "#2ca02c"},
                           "School Closures": {"name": "School Closures", "file": "data/school_wide.csv", "color": "#d62728"}};
                $(document).ready(function() {
                    $('#countrySearch').select2({dropdownAutoWidth: true,
                      multiple: true,
                      width: '100%',
                      closeOnSelect: false,
                      // include clear all selections button
                      allowClear: true,
                      // placeholder is necessary for allowClear to work
                      placeholder: 'Search for a country'});
                    
                    $('#countrySearch2').select2({dropdownAutoWidth: true,
                      multiple: false,
                      width: '100%',
                      closeOnSelect: false,
                      // include clear all selections button
                      allowClear: false,
                      // placeholder is necessary for allowClear to work
                      placeholder: 'Choose a policy type'});
                    
                    var country_names = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia", "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "European Union", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala",  "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Lithuania", "Macau", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Republic of the Congo", "Romania", "Russia", "Rwanda", "Saint Lucia", "Saint Vincent and the Grenadines", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"];

                  var searchBar = document.getElementById('countrySearch');

                  // add each country in dataset to dropdown
                  for (var i = 0; i < country_names.length; i++) {
                    var option = document.createElement('option');
                    option.text = country_names[i];
                    option.value = i;
                    searchBar.add(option, i);
                  }
                    
                    var policy_types = Object.keys(keys);
                    
                    var searchBar2 = document.getElementById('countrySearch2');

                  // add each country in dataset to dropdown
                  for (var i = 0; i < policy_types.length; i++) {
                    var option = document.createElement('option');
                    option.text = policy_types[i];
                    option.value = i;
                    if (i == 0) {
                        option.selected = true;
                    }
                    searchBar2.add(option, i);
                  }
                    
                    var g = new Dygraph(document.getElementById("indexPlot"), keys["Business Restrictions"]["file"],
                               {highlightCircleSize: 0,
                                highlightSeriesBackgroundAlpha: 0.3,
                                hideOnMouseOut: false,
                                color: keys["Business Restrictions"]["color"],
                                ylabel: "Policy Activity Score",
                                labelsSeparateLines: false,
                                showRangeSelector: true,
                                strokeBorderWidth: null,
                                highlightSeriesOpts: {
                                      strokeWidth: 3
                                    }
                                  });
                    
                    $('#countrySearch2').on('select2:select', function (e) {
                        var typeId = e.params.data.text;
                        $('#countrySearch').val(null).trigger('change');
                        
                        g = new Dygraph(document.getElementById("indexPlot"), keys[typeId]["file"],
                               {highlightCircleSize: 0,
                                highlightSeriesBackgroundAlpha: 0.3,
                                hideOnMouseOut: false,
                                color: keys[typeId]["color"],
                                ylabel: "Policy Activity Score",
                                labelsSeparateLines: false,
                                showRangeSelector: true,
                                strokeBorderWidth: null,
                                highlightSeriesOpts: {
                                      strokeWidth: 3
                                    }
                                  });
                    });

                  // change data on select
                  $('#countrySearch').on('select2:select', function (e) {
                    var countryId = e.params.data.id;
                    // if previously all displayed, show only the selected value
                    if (g.visibility().every(value => value === true)) {
                        g.visibility().fill(false);
                    }
                    g.visibility()[countryId] = true;
                    // dummy update to reload data
                    g.updateOptions({'showRangeSelector': false});
                  });

                    // change data on deselect
                  $('#countrySearch').on('select2:unselect', function (e) {
                    var countryId = e.params.data.id;
                    g.visibility()[countryId] = false;
                    // if all values deselected, show all countries
                    if (g.visibility().every(value => value === false)) {
                        g.visibility().fill(true);
                    }
                    // dummy update to reload data
                    g.updateOptions({'showRangeSelector': false});
                  });
                });