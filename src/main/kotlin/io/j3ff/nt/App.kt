/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package io.j3ff.nt

import edu.wpi.first.networktables.NetworkTableInstance


fun main(args: Array<String>) {
    val nt = NetworkTableInstance.getDefault()
    nt.startServer()
    do Thread.sleep(2000L)
    while (true)
}