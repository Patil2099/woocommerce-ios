/// Models a Card Reader. This is the public struct that clients of
/// Hardware are expected to consume.
/// The exact properties are to be defined yet.
/// For now, this is a placeholder
public struct CardReader {
    public let status: CardReaderStatus
    public let name: String
    public let serial: String
}
