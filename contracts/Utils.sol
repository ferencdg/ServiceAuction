// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

library Utils {

    /// returns a input[begin, end) as bytes
    function sliceBytes32(
        bytes32 input,
        uint8 begin,
        uint8 end
    ) public pure returns (bytes memory) {
        require(begin >= 0);
        require(end <= 32);
        require(end > begin);

        bytes memory res = new bytes(end - begin);

        for (uint256 i = begin; i < end; i++) {
            res[i - begin] = input[i];
        }
        return res;
    }

    /// returns bool, if the compared bytes match
    function compareBytes(bytes memory a, bytes memory b)
        public
        pure
        returns (bool)
    {
        if (a.length != b.length) return false;

        for (uint256 i = 0; i < a.length; i++) if (a[i] != b[i]) return false;

        return true;
    }

    event DebS(string);
    event DebUint(uint256);
    event DebAddr(address payable);
    event DebBytes(bytes);

}
