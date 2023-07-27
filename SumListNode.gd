class_name SumListNode

var val : int
var sum : int
var prev : SumListNode

func _init(val: int, prev: SumListNode):
	self.val = val
	self.prev = prev
	if(prev == null):
		sum = val
	else:
		sum = prev.sum + val

func save(arr = []):
	arr.append(val)
	if prev == null:
		return arr
	else:
		return prev.save(arr)
