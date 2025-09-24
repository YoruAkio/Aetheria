#include "pch.hpp"
#include "https.hpp"
#include "httplib/httplib.h" // @note using httplib for https server

void https::listener(_server_data server_data)
{
    // @note create ssl server using httplib
    httplib::SSLServer svr("resources/ctx/server.crt", "resources/ctx/server.key");

    if (!svr.is_valid()) {
        std::cerr << "failed to create ssl server" << std::endl;
        return;
    }

    // @note set server options for better performance and security
    svr.set_address_family(AF_INET);
    svr.set_tcp_nodelay(true);

    // @note format server data response
    const std::string content =
        std::format(
            "server|{}\n"
            "port|{}\n"
            "type|{}\n"
            "type2|{}\n"
            "#maint|{}\n"
            "loginurl|{}\n"
            "meta|{}\n"
            "RTENDMARKERBS1001",
            server_data.server, server_data.port, server_data.type, server_data.type2, server_data.maint, server_data.loginurl, server_data.meta
        );

    // @note handler for growtopia server data endpoint
    svr.Post("/growtopia/server_data.php", [&](const httplib::Request& req, httplib::Response& res) {
        // @note set response headers
        res.set_header("Content-Type", "text/plain");
        res.set_header("Connection", "close");

        // @note return server data
        res.set_content(content, "text/plain");
    });

    // @note handler for any other requests (optional)
    svr.Get(".*", [&](const httplib::Request& req, httplib::Response& res) {
        res.set_header("Content-Type", "text/plain");
        res.set_content("server active", "text/plain");
    });

    // @note start listening on port 443
    printf("listening on %s:%d\n", server_data.server.c_str(), server_data.port);

    if (!svr.listen("0.0.0.0", 443)) {
        std::cerr << "failed to start server on port 443" << std::endl;
        return;
    }
}
