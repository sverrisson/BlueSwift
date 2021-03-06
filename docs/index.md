# Motivation:

For the past previous years I've worked with several apps related to Bluetooth LE technology.
At the start of every project I've came to a few conclusions:
- CoreBluetooh delegate based API is horrible and really full of boilerplate
- I had to write many small MVP projects(eg. for testing purposes) that made point 1 even more horrible

That's pretty much everything that motivated me to create a library that will handle connection and data tranfer in just a couple of lines.
I've also felt that it should be handled by closures instead of delegation for easier management.
Below you'll find a bit more thoroughly explained examples along with small documentation piece for every public class used in this project.
Let's go with connection first.

# Connection:

Starting with some code to be described in detail later:

```swift
let connection = BluetoothConnection.shared
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid", shouldObserveNotification: true)
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_advertising_uuid")
let peripheral = Peripheral(configuration: configuration)
connection.connect(peripheral) { _ in
	// do sth
}
```

the idea behind above lines is to create a specification of the expected device with a configuration file.
You should create an instance of `Characteristic` or `Service` classes for each existing ones expected in a connecting device.
Only if all specified characteristics and services are found on device, it's connected with no error.
Please note that you don't have to specify everything contained in the device, just the one's you'll use.
After that a peripheral object is created with a passed configuration, it should be persisted by some instance variable as it will be used to manage connection.
If you wish to ceonnect multiple devices, create multiple peripheral.
The library contains a built in singleton instance of `BluetoothConnection`, you can easily use your own instance, but creating it will create a separate `CBCentralManager` instance, and according to Apple documentation, creating more than one instance is not recommended.

```swift
let command = Command.utf8String("Hello world")
peripheral.write(command: command, characteristic: someCharacteristic, handler: { error in
	// do sth
})
```

The library has a built in enum for simple conversions. It may sound easy but it's really convenient :)
Using a simple enum you can create input data of cerrect bit size from integers, convert custom strings to hexadecimal and, if needed, pass data created on your own.
This input data should be passed by `write` method on a peripheral that was previously used to connect. Also characteristic should be passed, this also should be the one used to create configuration for this peripheral instance.
If nil error is returned in the closure, write request succeed.

```swift
peripheral.read(characteristic, handler: { data, error in
	// do sth
})
```

Reading values from characteristics is actually pretty similar to writing them, you should grab on the `Peripheral` object instance used for connection, fetch desired characteristic(should also be the one used for creating configuration).
As the result is asynchronous, it's returned by closure - if error there is nil, reading scceed and Data object can be read.

```swift
characteristic.notifyHandler = { data in
	// do sth
}
```

Do you maybe remember a moment when you had to subscribe to a characteristic and wait for value updates? With `CoreBluetooth` alone this was hell, right?
Here you have a convenient closure in every `Characteristic` object instance. It will be called each time a value changes there. The only prerequisite is to call:
`shouldObserveNotification: true)` in your characteristic initializer, only this way a proper variable will be set after connection and observation will be visible.

# Advertisement:

```swift
let characteristic = try! Characteristic(uuid: "your_characteristic_uuid")
let service = try! Service(uuid: "your_service_uuid", characteristics: [characteristic])
let configuration = try! Configuration(services: [service], advertisement: "your_service_uuid")
let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("your_service_uuid")])
advertisement.advertise(peripheral: peripheral) { _ in
	// handle possible error            
}
```

Advertisement setup is actually not that much different than connection. The main idea of creating a configuration that will specify all services and characteristics of the device is kept, only details varies.

```swift
let command = Command.int8(3)
advertisement.update(command, characteristic: characteristic) { error in
	// notified subscribed centrals
}
```

Above method uses `Command` enum to create a `Data` object that will be updated on a given characteristic. It wil autmoatically update the value on each central that is currently subscribed to that characteristic.

```swift
advertisement.writeRequestCallback = { characteristic, data in
	// handle write request
}
```

If you wish to handle write requests from connected centrals, assign custom value to that closure, each write attempt will be called there with associated data and characteristic.

```swift
advertisement.readRequestCallback = { characteristic -> Data in
	// respond to read request
}
```

If you wish to handle read requests from connected centrals, assign custom value to that closure, each write attempt will be called there with associated characteristic. You should return any data that should be responded.

# Public classes documentation:

[BluetoothConnection](./bluetoothConnection.md)

[Service](./service.md)

[Characteristic](./characteristic.md)

[Configuration](./configuration.md)

[Peripheral](./peripheral.md)

[Command](./command.md)

[BluetoothAdvertisement](./bluetoothAdvertisement.md)

[AdvertisementData](./advertisementData.md)
