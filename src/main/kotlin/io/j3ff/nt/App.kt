package io.j3ff.nt

import edu.wpi.first.networktables.NetworkTableInstance


fun main() {
    val networkIdentity = System.getenv("NT_IDENTITY") ?: "NetworkTables Server"
    val persistFile = "${System.getenv("STATE_DIRECTORY") ?: "/tmp"}/networktables.ini"
    val port = System.getenv("NT_PORT")?.toIntOrNull() ?: 1735

    val nt = NetworkTableInstance.getDefault().apply {
        addLogger({ println(it.message) }, 11, 100)
        startServer()
    }

    Runtime.getRuntime().addShutdownHook(Thread { nt.stopServer() })

    println("$networkIdentity listening on port $port")
    println("$networkIdentity saving state to $persistFile")

    do {
        Thread.sleep(500L)
    } while (true)
}
