//  _____ _
// |_   _| |_  _ _ ___ ___ _ __  __ _
//   | | | ' \| '_/ -_) -_) '  \/ _` |_
//   |_| |_||_|_| \___\___|_|_|_\__,_(_)
//
// Threema iOS Client
// Copyright (c) 2015-2020 Threema GmbH
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

#ifndef Threema_EditGroupDelegate_h
#define Threema_EditGroupDelegate_h

#import "GroupProxy.h"

@protocol EditGroupDelegate <NSObject>

- (void)group:(GroupProxy *)group updatedName:(NSString *)newName;
- (void)group:(GroupProxy *)group updatedImage:(NSData *)newImage;

- (void)group:(GroupProxy *)group updatedMembers:(NSSet *)newMembers;

@end

#endif
