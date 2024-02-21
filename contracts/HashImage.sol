pragma solidity >=0.5.0;

contract HashImage {
    string public name = "HashImage"; // Contract name
    uint256 public imageCount = 0; // Counter for tracking the number of images
    mapping(uint256 => Image) public images; // Mapping to store images by their ID

    struct Image {
        uint256 id; // Image ID
        string hash; // IPFS hash of the image
        string description; // Description of the image
        uint256 tipAmount; // Amount of tips received for the image
        address payable author; // Address of the image author
    }

    event ImageCreated(uint256 indexed id, string hash); // Event emitted when a new image is uploaded
    event ImageTipped(uint256 indexed id, uint256 tipAmount); // Event emitted when an image is tipped

    // Function to upload a new image
    function uploadImage(string calldata _imgHash, string calldata _description) external {
        require(bytes(_imgHash).length > 0, "Image hash cannot be empty");
        require(bytes(_description).length > 0, "Image description cannot be empty");
        require(msg.sender != address(0), "Invalid uploader address");

        imageCount++;
        images[imageCount] = Image(imageCount, _imgHash, _description, 0, payable(msg.sender));

        emit ImageCreated(imageCount, _imgHash);
    }

    // Function to tip the author of an image
    function tipImageOwner(uint256 _id) external payable {
        require(_id > 0 && _id <= imageCount, "Invalid image ID");
        Image storage _image = images[_id];
        address payable _author = _image.author;

        require(_author != address(0), "Invalid author address");

        // Transfer the tip amount to the author
        (bool success, ) = _author.call{value: msg.value}("");
        require(success, "Failed to send tip");

        // Update the tip amount for the image
        _image.tipAmount += msg.value;
        images[_id] = _image;

        emit ImageTipped(_id, msg.value);
    }
}
