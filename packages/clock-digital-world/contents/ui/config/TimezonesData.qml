import QtQuick

QtObject {
    property var timezones: [
        // DST: hasDST indicates if timezone observes DST, dstOffset is additional hours during DST
        { id: "Europe/Rome", city: "Rome", country: "IT", offset: 1.0 },
        { id: "Europe/Madrid", city: "Madrid", country: "ES", offset: 1.0 },
        { id: "Europe/Amsterdam", city: "Amsterdam", country: "NL", offset: 1.0 },
        { id: "Europe/Zurich", city: "Zurich", country: "CH", offset: 1.0 },
        { id: "Europe/Vienna", city: "Vienna", country: "AT", offset: 1.0 },
        { id: "Europe/Stockholm", city: "Stockholm", country: "SE", offset: 1.0 },
        { id: "Europe/Oslo", city: "Oslo", country: "NO", offset: 1.0 },
        { id: "Europe/Copenhagen", city: "Copenhagen", country: "DK", offset: 1.0 },
        { id: "Europe/Helsinki", city: "Helsinki", country: "FI", offset: 2.0 },
        { id: "Europe/Warsaw", city: "Warsaw", country: "PL", offset: 1.0 },
        { id: "Europe/Prague", city: "Prague", country: "CZ", offset: 1.0 },
        { id: "Europe/Budapest", city: "Budapest", country: "HU", offset: 1.0 },
        { id: "Europe/Athens", city: "Athens", country: "GR", offset: 2.0 },
        { id: "Europe/Lisbon", city: "Lisbon", country: "PT", offset: 0.0 },
        { id: "Europe/Dublin", city: "Dublin", country: "IE", offset: 0.0 },

        { id: "Africa/Cairo", city: "Cairo", country: "EG", offset: 2.0 },
        { id: "Africa/Johannesburg", city: "Johannesburg", country: "ZA", offset: 2.0 },
        { id: "Africa/Lagos", city: "Lagos", country: "NG", offset: 1.0 },
        { id: "Africa/Nairobi", city: "Nairobi", country: "KE", offset: 3.0 },
        { id: "Africa/Accra", city: "Accra", country: "GH", offset: 0.0 },

        { id: "Asia/Beirut", city: "Beirut", country: "LB", offset: 2.0 },
        { id: "Asia/Jerusalem", city: "Jerusalem", country: "IL", offset: 2.0 },
        { id: "Asia/Riyadh", city: "Riyadh", country: "SA", offset: 3.0 },
        { id: "Asia/Doha", city: "Doha", country: "QA", offset: 3.0 },
        { id: "Asia/Kuwait", city: "Kuwait City", country: "KW", offset: 3.0 },
        { id: "Asia/Manila", city: "Manila", country: "PH", offset: 8.0 },
        { id: "Asia/Jakarta", city: "Jakarta", country: "ID", offset: 7.0 },
        { id: "Asia/Ho_Chi_Minh", city: "Ho Chi Minh City", country: "VN", offset: 7.0 },
        { id: "Asia/Kathmandu", city: "Kathmandu", country: "NP", offset: 5.75 },
        { id: "Asia/Colombo", city: "Colombo", country: "LK", offset: 5.5 },
        { id: "Asia/Karachi", city: "Karachi", country: "PK", offset: 5.0 },
        { id: "Asia/Taipei", city: "Taipei", country: "TW", offset: 8.0 },

        { id: "Australia/Melbourne", city: "Melbourne", country: "AU", offset: 10.0 },
        { id: "Australia/Perth", city: "Perth", country: "AU", offset: 8.0 },
        { id: "Australia/Brisbane", city: "Brisbane", country: "AU", offset: 10.0 },
        { id: "Pacific/Fiji", city: "Suva", country: "FJ", offset: 12.0 },
        { id: "Pacific/Honolulu", city: "Honolulu", country: "US", offset: -10.0 },

        { id: "America/Atlanta", city: "Atlanta", country: "US", offset: -5.0 },
        { id: "America/Detroit", city: "Detroit", country: "US", offset: -5.0 },
        { id: "America/Seattle", city: "Seattle", country: "US", offset: -8.0 },
        { id: "America/Anchorage", city: "Anchorage", country: "US", offset: -9.0 },
        { id: "America/Indianapolis", city: "Indianapolis", country: "US", offset: -5.0 },

        { id: "America/Buenos_Aires", city: "Buenos Aires", country: "AR", offset: -3.0 },
        { id: "America/Lima", city: "Lima", country: "PE", offset: -5.0 },
        { id: "America/Bogota", city: "Bogotá", country: "CO", offset: -5.0 },
        { id: "America/Santiago", city: "Santiago", country: "CL", offset: -4.0 },
        { id: "America/Caracas", city: "Caracas", country: "VE", offset: -4.0 },

        { id: "America/Panama", city: "Panama City", country: "PA", offset: -5.0 },
        { id: "America/Guatemala", city: "Guatemala City", country: "GT", offset: -6.0 },

        { id: "Atlantic/Reykjavik", city: "Reykjavik", country: "IS", offset: 0.0 },
        { id: "Atlantic/Bermuda", city: "Hamilton", country: "BM", offset: -4.0 }

    ]
}
