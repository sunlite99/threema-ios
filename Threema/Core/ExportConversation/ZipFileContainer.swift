//  _____ _
// |_   _| |_  _ _ ___ ___ _ __  __ _
//   | | | ' \| '_/ -_) -_) '  \/ _` |_
//   |_| |_||_|_| \___\___|_|_|_\__,_(_)
//
// Threema iOS Client
// Copyright (c) 2020 Threema GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License, version 3,
// as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import Foundation
import ZipArchive
import CocoaLumberjackSwift

class ZipFileContainer: NSObject {
    private var zipFilePath: String
    private var password: String
    private var zipFile: SSZipArchive
    
    static let directoryPath = NSTemporaryDirectory() + "Export/"
    
    init(password: String, name: String) {
        self.zipFilePath = ZipFileContainer.getZipFilePath(name: name)
        self.password = password
        self.zipFile = SSZipArchive.init(path: self.zipFilePath)
        self.zipFile.open()
        super.init()
    }
    
    /// Adds data to the zip file in _zipfile and encrypts it with _password and AES.
    /// Does not return an error if it does not succeed
    /// - Parameters:
    ///   - data: The data that will be added to the zipFile
    ///   - filename: The filename with which data is added to the zip file
    func addData(data: Data, filename: String) -> Bool {
        let success = self.zipFile.write(data,
                                         filename: filename,
                                         compressionLevel: 0,
                                         password: self.password,
                                         aes: true)
        return success
    }
    
    func addMediaData(mediaData: BlobData) -> Bool {
        return self.addData(data: mediaData.blobGet(), filename: mediaData.blobGetFilename())
    }
    
    func deleteFile() {
        self.zipFile.close()
        let fileManager = FileManager.default
        
        if fileManager.isDeletableFile(atPath: self.zipFilePath) {
            do {
                try fileManager.removeItem(atPath: self.zipFilePath)
            } catch {
                DDLogError("Unable to delete chat export from temporary files.")
            }
        }
    }
    
    static func cleanFiles() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.removeItem(atPath: directoryPath)
            } catch let error as NSError {
                DDLogError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getUrlWithFileName(fileName: String) -> URL? {
        self.zipFile.close()
        
        let path = ZipFileContainer.getZipFilePath(name: fileName)
        let fileManager = FileManager.default
        
        do {
            try fileManager.moveItem(atPath: self.zipFilePath, toPath: path)
            return NSURL.fileURL(withPath: path)
        } catch {
            DDLogError("An error occurred when moving the zip file within temporary files.")
            DDLogError("Unexpected error: \(error).")
        }
        return nil
    }
    
    private static func getZipFilePath(name: String) -> String {
        return ZipFileContainer.getDirectoryPath() + name + ".zip"
    }
    
    private static func getDirectoryPath() -> String {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(atPath: directoryPath,
                                                withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                DDLogError("Error: \(error.localizedDescription)")
            }
        }
        return directoryPath
    }
}
