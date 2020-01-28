#!/bin/bash
swift package update && swift package generate-xcodeproj && ./update.rb && open Wishlist.xcodeproj/

