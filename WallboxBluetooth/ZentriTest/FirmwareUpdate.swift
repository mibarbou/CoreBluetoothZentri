//
//  FirmwareUpdate.swift
//  ZentriTest
//
//  Created by Santi on 29/01/2019.
//  Copyright © 2019 Wallbox Chargers. All rights reserved.
//

import Foundation

class FirmwareUpdate {
	
	enum Mode {
		case stream
		case remote
	}
	
	enum Action {
		case command(_ command: String)
		case changeMode(_ mode: Mode)
		case kernel(data: Data)
		case firmware(data: Data)
	}
	
	let commands = [
		"set sy c e 0",
		"set sy c e 0",
		"set sy c h 0",
		"set sy p 0",
		"set sy c p 0",
		"set bu s s 0",
		"set bu s s none",
		"set sy c e 0",
		"set sy c h 0",
		"get ua b",
		"set ua b 19200",
		"gfu 10 stdio",
		"gfu 11 stdio",
		"gdi 10 ohi",
		"gdi 11 ohi",
		"save",
		"reboot",
		"gse 10 0",
		"gse 11 0",
		"gse 11 1",
		"A",
		"KERNELFILE",
		"A",
		"FIRMWAREFILE"
	]
	
	private var currentCommand = 0
	private var lastCommand: String? = nil
	private var kernelSent = false
	private var firmwareSent = false
	private var kernelCharacters: [String] = []
	private var currentKernelPosition = 0
	
	var currentMode: Mode? = nil
	
	init(mode: Mode) {
		self.currentMode = mode
		loadKernel()
	}
	
	func nextAction(response: String) -> Action {
		
		if lastCommand == "get ua b" {
			if response.contains("19200") {
				currentCommand += 1
			}
		}
		
		if currentCommand >= commands.count {
			print("Update firmware finish!!!")
			return .command("reboot")
		}
		
		let nextCommand = commands[currentCommand]
		
		if nextCommand.requireStreamMode && currentMode == .remote {
			return .changeMode(.stream)
		}
		
		if nextCommand == "KERNELFILE" {
			if let nextData = nextKernelData() {
				return .kernel(data: nextData)
			}
		}
		
		lastCommand = nextCommand
		currentCommand += 1
		print(nextCommand)
		return .command(nextCommand)
	}
	
	fileprivate func loadKernel() {
		guard let filepath = Bundle.main.path(forResource: "kernel", ofType: "txt") else {
			print("kernel.txt not found")
			return
		}
		
		do {
			var kernelContent = try String(contentsOfFile: filepath, encoding: .utf8)
			kernelContent = kernelContent.replacingOccurrences(of: "\n", with: "")
			kernelContent = kernelContent.replacingOccurrences(of: "\r", with: "")
			self.kernelCharacters = kernelContent.map { String($0) }
		} catch {
			print("Kernel content not found")
		}
		
	}
	
	fileprivate func nextKernelData() -> Data? {
		
		let percent = (currentKernelPosition * 100) / kernelCharacters.count
		print("Kernel percent: \(percent)")
		
		if currentKernelPosition+1 < kernelCharacters.count {
			let nextTwoCharacters = String(kernelCharacters[currentKernelPosition]) + String(kernelCharacters[currentKernelPosition+1])
			if var value = UInt8(nextTwoCharacters, radix: 16) {
				return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
			}
		}
		
		return nil
		
	}
	
}

private  extension String {
	
	var requireStreamMode: Bool {
		return self == "A" || self == "KERNELFILE" || self == "FIRMWAREFILE"
	}
	
}
